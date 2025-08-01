# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ pkgs, pkgs-stable, ... }: {
  imports = [
    ./hardware-configuration.nix # Include the results of the hardware scan.
  ];

  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot"; # assuming /boot is the mount point of the EFI partition in NixOS (as the installation section recommends).
      };

      grub = {
        # despite what the configuration.nix manpage seems to indicate,
        # as of release 17.09, setting device to "nodev" will still call
        # `grub-install` if efiSupport is true
        # (the devices list is not used by the EFI grub install,
        # but must be set to some value in order to pass an assert in grub.nix)
        devices = [ "nodev" ];
        efiSupport = true;
        enable = true;
        useOSProber = true; # ~~ false; # we should be using rEFInd~~ <- it's kinda weird atm...
        efiInstallAsRemovable = false;
      };
    };

    plymouth.enable = true;
  };

  powerManagement.enable = true;

  hardware = {
    steam-hardware.enable = true;
    xone.enable = true;

    graphics = {
      enable = true;
      enable32Bit = true; # For steam specifically, but will be for all of opengl...

      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        libvdpau-va-gl
        mesa
        intel-media-sdk
        vpl-gpu-rt
      ];
    };

    opentabletdriver = {
      enable = true;
      daemon.enable = true;
    };

    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  time.timeZone = "America/Phoenix";

  networking = {
    firewall = {
      # Open ports in the firewall.
      allowedTCPPortRanges = [ { from = 47984; to = 48010; } ];
      allowedUDPPortRanges = [ { from = 47998; to = 48010; } ];
      allowedTCPPorts = [ 3389 4455 3333 4444 50001 5567 1701 9001 4001 ];
      allowedUDPPorts = [ 3389 4455 4444 50001 5567 1701 9001 4001 ];

      enable = false; # Or disable the firewall altogether.~~
    };
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;

    # For hibernation
    protectKernelImage = false;

    wrappers.sunshine = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+p";
      source = "${pkgs.sunshine}/bin/sunshine";
    };
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    roboto
    roboto-serif
    corefonts # the msft ones, seems to not load.
		noto-fonts-cjk-sans
		noto-fonts-cjk-serif
  ];

  systemd.services = {
    syncthing = {
      description = "Run Syncthing";
      serviceConfig = {
        ExecStart = "${pkgs.syncthing}/bin/syncthing";
        User = "reboot";
      };
    };
  };

  virtualisation = {
    waydroid.enable = true;
    containers.enable = true;

    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;

      defaultNetwork.settings.dns_enabled = true;
    };

    virtualbox.host.enable = true;
    virtualbox.host.enableExtensionPack = true; # Requires previous, will compile all of vbox if enabled!

    libvirtd = {
      enable = true;

      qemu = {
				package = pkgs-stable.qemu;
        swtpm.enable = true;
        ovmf.enable = true;
      };
    };

    appvm = {
      enable = true;
      user = "reboot";
    };

    spiceUSBRedirection.enable = true;
  };

  programs = {
    anime-game-launcher.enable = true; # Adds launcher and /etc/hosts rules
    anime-games-launcher.enable = true;
    honkers-railway-launcher.enable = true;
    honkers-launcher.enable = true;
    wavey-launcher.enable = true;
    sleepy-launcher.enable = true;

    neovim = {
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
    };

    adb.enable = true;
    virt-manager.enable = true;
    nbd.enable = true;
    xwayland.enable = true;
    hyprland.enable = true;
    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # mtr.enable = true;

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
      protontricks.enable = true;
    };

    gamemode.enable = true;
    dconf.enable = true;
  };

  xdg.portal = {
    enable = true;

    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
      xdg-desktop-portal-hyprland
    ];

    config = {
      common = {
        default = [ "kde" ];
      };

      hyprland = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = "kde";
      };
    };
  };

  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    zerotierone = {
      enable = true;

      joinNetworks = [
        "56374ac9a475ea79"
      ];
    };

    pulseaudio.enable = false; # This is a pipewire-based system!
    hardware.openrgb.enable = true;

    btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = [ "/" ];
    };

    libinput.enable = true;
    pcscd.enable = true;

    udev.packages = with pkgs; [
      qmk-udev-rules
      android-udev-rules
    ];

    ratbagd.enable = true;
    k3s.enable = true;
    teamviewer.enable = true;

    printing = {
      enable = true;

      drivers = with pkgs; [
        brlaser
        brgenml1lpr
        brgenml1cupswrapper
      ];
    };

    kubo = {
      enable = true;

      settings.Addresses = {
        API = [ "/ip4/127.0.0.1/tcp/5001" ];

        Swarm = [
          "/ip4/0.0.0.0/tcp/4001"
          "/ip6/::/tcp/4001"
          "/ip4/0.0.0.0/udp/4001/quic-v1"
          "/ip4/0.0.0.0/udp/4001/quic-v1/webtransport"
          "/ip6/::/udp/4001/quic-v1"
          "/ip6/::/udp/4001/quic-v1/webtransport"
        ];
      };
    };

    sunshine = {
      enable = true;
      openFirewall = true;
    };

    desktopManager.plasma6.enable = true;

    displayManager = {
      defaultSession = "plasma";
    };

    xserver = {
      enable = true;

      displayManager.lightdm = {
				greeter.enable = true;

				greeters.gtk = {
					enable = true;
				};
			};

      xkb = {
        layout = "us";
        variant = "";
      };
    };

    # displayManager.sddm.enable = true; # It's kinda broken right now.
    spice-autorandr.enable = true;

    # This doesn't work btw, afaik. Use the one in plasma!
    # xrdp = {
    #   enable = true;
    #   defaultWindowManager = "plasmashell";
    #   openFirewall = true;
    # };

    avahi.publish = {
      enable = true;
      userServices = true;
    };

    # https://nixos.wiki/wiki/IOS
    usbmuxd = {
      enable = true;
      package = pkgs.usbmuxd2;
    };

    flatpak = {
      enable = true;

      packages = [
        "dev.vencord.Vesktop"
        "net.davidotek.pupgui2"
        "com.github.tchx84.Flatseal"
        "org.signal.Signal"
        "io.github.hydrusnetwork.hydrus"
      ];
    };
  };

  environment = {
    sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };

    systemPackages = (with pkgs; [
      # Utils
      cryptsetup
      vim
      neovim
      busybox
      wget
      file
      xxd
      unzip
      zip
      progress
      tldr
      eza
      fastfetch
      btop
      htop
      at
      tmux
      starship
      fortune
      lolcat
      screen
      git
      signify
      cachix
      solaar
      arrpc

      # Shells
      zsh
      bash

      # System
      man-pages
      glibcInfo
      stdmanpages
      c-intro-and-ref
      tkman
      wikiman
      stdman
      texinfo
      nixpkgs-manual
      wl-clipboard
      gnupg
      libnotify
      appimage-run
      xorg.xhost
      glfw
      freetype
      vulkan-headers
      vulkan-loader
      vulkan-validation-layers
      vulkan-tools        # vulkaninfo
      alsa-utils
      fluidsynth
      soundfont-fluid
      soundfont-arachno
      soundfont-ydp-grand
      soundfont-generaluser
      x42-gmsynth
      direnv

      # Hardware
      pciutils
      dmidecode
      usbutils
      libva-utils
      pmutils
      refind
      efibootmgr
      smartmontools
      glxinfo
      piper
      openrgb-with-all-plugins

      # Network
      nmap
      socat
      openssl
      speedtest-cli

      # FS Manipulation
      btrfs-progs
      btrbk
      fuzzel
      sshfs
      exfat
      ntfs3g
      mtpfs
      libimobiledevice
      ifuse

      # Python
      # python3Full
      pipx

      # Global Apps
      firefox
      links2
      alacritty
      qpwgraph

      # media manipulation
      mpv
      imagemagickBig
      ffmpeg

      # Services
      sunshine
      zerotierone
      syncthing
      nicotine-plus

      # Alt DE
      waybar
      wofi
      wpaperd
      hyprlock
      hyprcursor
      hypridle
      dunst
      kitty
      kitty-img
      kitty-themes

      # QT
      kdePackages.qt6ct
      kdePackages.breeze
      libsForQt5.qt5ct
      kdePackages.breeze-gtk
			kdePackages.kdialog

      # VMs and Containers
      dive
      podman-tui
      docker-compose
      podman-compose
      virtiofsd
      appvm
    ]);
  };
}
