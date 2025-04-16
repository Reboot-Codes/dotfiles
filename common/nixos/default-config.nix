{ pkgs, lib, config, rust-overlay, nixGL, hostConfig, ... }: {
  imports = [
    ../home
  ];

  # Enable flake support, since that's "experimental" (despite most new installs using flakes anyways).
  nix = {
		settings = {
			experimental-features = [ "nix-command" "flakes" ];
			trusted-users = [ "${hostConfig.username}" ];
		};

		gc = {
			automatic = true;
			persistent = true;
			dates = "weekly";
		};
	};

  nixpkgs = {
    config = import ../utils/nix-config.nix;

    overlays = [
      nixGL.overlays.default
      rust-overlay.overlays.default
    ] ++ import ../overlays;
  };

  # nix.settings.auto-optimise-store = true; # Slow AF

  # TL;DR: Don't change this, **EVER**.
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  boot = {
    loader.grub = {
      configurationLimit = 15;
      theme = import ../derivations/distro-grub-themes.nix { inherit pkgs; };
    };

    kernelPackages = pkgs.linuxPackages_zen;

    extraModulePackages = with config.boot.kernelPackages; [
      usbip
      # apfs
      kvmfr
      # gasket
      # shufflecake
      v4l2loopback
			systemtap
			vendor-reset
    ];

    kernelParams = [
      "psi=1" # Enable PSI to make sure that Binder doesn't die when using Waydroid.
    ];
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  networking = {
    networkmanager.enable = true;
    wireless.enable = false;
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };

  programs = {
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      zsh-autoenv.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        nix-update = "CUSTOMZSHCONSOLEPREVWORKINGDIR=$(pwd) cd /etc/nixos && sudo nix flake update && sudo nixos-rebuild switch --flake .# --impure -L --show-trace; cd $CUSTOMZSHCONSOLEPREVWORKINGDIR";
        nix-rebuild = "sudo nixos-rebuild switch --flake /etc/nixos/# --impure -L --show-trace";
        nix-config = "sudo nvim /etc/nixos/configuration.nix";
        nix-clean = "nix-store --gc";
        start-default-virtd-network = "sudo virsh net-start default";
        clear-qmlcache = "find $${XDG_CACHE_HOME:-$HOME/.cache}/**/qmlcache -type f -delete";
        ll = "eza -l --icons";
        ls = "eza --icons";
        tree = "eza --icons --tree --git-ignore";
        waydroid-attach-user-folders = ''
          sudo mount --bind ~/Documents ~/.local/share/waydroid/data/media/0/Documents
          sudo mount --bind ~/Downloads ~/.local/share/waydroid/data/media/0/Download
          sudo mount --bind ~/Music ~/.local/share/waydroid/data/media/0/Music
          sudo mount --bind ~/Pictures ~/.local/share/waydroid/data/media/0/Pictures
          sudo mount --bind ~/Videos ~/.local/share/waydroid/data/media/0/Movies
        '';
      };

      ohMyZsh = {
        enable = true;
        theme = "robbyrussell";
      };
    };

		java = {
      enable = true;
      binfmt = true;
    };

		nix-ld = {
			enable = true;
      libraries = import ../utils/nix-ld.nix { inherit pkgs lib; };
    };

    command-not-found.enable = true; # This basically doesn't work imo.
    appimage.binfmt = true;
  };

  services = {
    openssh.enable = true;
    atd.enable = true;
		envfs.enable = true;

    tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };

    tor = {
      enable = true;

      client = {
        enable = true;
        dns.enable = true;
        transparentProxy.enable = true;

        socksListenAddress = {
          addr = "127.0.0.1";
          port = 9050;
        };
      };
    };

    flatpak = {
      remotes = [
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
        {
          name = "flathub-beta";
          location = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
        }
      ];

      update.auto = {
        enable = true;
        onCalendar = "weekly";
      };

      overrides = {
        global = {
          Context = {
            filesystems = [
              "/home/reboot/.icons,ro"
              "/run/current-system/sw/share/X11/fonts:ro"
              "/nix/store:ro"
              "/home/reboot/.config/gtk-2.0/:ro"
              "/home/reboot/.config/gtk-3.0/:ro"
              "/home/reboot/.config/gtk-4.0/:ro"
       	      "/home/reboot/.config/gtkrc:ro"
       	      "/home/reboot/.config/gtkrc-2.0:ro"
            ];

            # sockets = ["wayland" "!x11" "fallback-x11"];
          };

          Environment = {
            XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons:/home/reboot/.icons";
          };
        };

        "org.signal.Signal".Environment = {
          ELECTRON_OZONE_PLATFORM_HINT="auto";
        };
      };

      restartOnFailure = {
        enable = true;
        restartDelay = "60s";
        exponentialBackoff = {
          enable = false;
          steps = 10;
          maxDelay = "1h";
        };
      };
    };
  };

  users = {
    defaultUserShell = pkgs.zsh;

    users."${hostConfig.username}" = {
      isNormalUser = true;
      description = "Reboot"; # GCOS Field, basically the Pretty Name for this user.

      extraGroups = [
        "networkmanager"
        "wheel"
        "adbuser"
        "docker"
        "libvirtd"
        "kvm"
        "adbusers"
        "xrdp"
        "gamemode"
        "video"
        config.services.kubo.group
      ];
    };
  };

  fonts.fontDir.enable = true;

  environment = {
    # Install Soundfonts TODO: only Fluid copies over... might wanna fix that soon.
    etc = {
      "/soundfonts/FluidR3_GM2-2.sf2".source = "${pkgs.soundfont-fluid}/share/soundfonts/FluidR3_GM2-2.sf2";
      "/share/soundfonts/arachno.sf2".source = "${pkgs.soundfont-arachno}/share/soundfonts/arachno.sf2";
      "/share/soundfonts/GeneralUser-GS.sf2".source = "${pkgs.soundfont-generaluser}/share/soundfonts/GeneralUser-GS.sf2";
      "/share/soundfonts/YDP-GrandPiano.sf2".source = "${pkgs.soundfont-ydp-grand}/share/soundfonts/YDP-GrandPiano.sf2";
    };

    shellInit = ''
      gpg-connect-agent /bye
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    '';

    shells = with pkgs; [ zsh ];
  };
}
