{ pkgs, pkgs-stable, config, options, home-manager, flatpaks, rust-overlay, nur, chaotic, aagl, nixGL, hostConfig, lib, specialArgs, ... }: {
  imports = [
    ../utils
    ../home
  ];

  # Enable flake support, since that's "experimental" (despite most new installs using flakes anyways).
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "${hostConfig.username}" ];
  };

  nixpkgs = {
    config = {
      allowUnfree = true;

      permittedInsecurePackages = [
        "electron-25.9.0"
      ];

      packageOverrides = pkgs: {
        intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
      };
    };

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
      theme = import ../common/derivations/distro-grub-themes.nix { inherit pkgs; };
    };

    kernelPackages = pkgs.linuxPackages_zen;

    extraModulePackages = with config.boot.kernelPackages; [
      usbip
      apfs
      kvmfr
      xone
      gasket
      # shufflecake
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

    command-not-found.enable = true; # This basically doesn't work imo.
    nix-ld.enable = true;
    appimage.binfmt = true;
  };

  services = {
    openssh.enable = true;
    atd.enable = true;

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
        config.services.kubo.group
      ];
    };
  };

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