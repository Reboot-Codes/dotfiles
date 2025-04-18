# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, lib, ... }: let
  # TODO: Check if this exists and is the right display.
  virtualDisplayId = "HDMI-A-1";

	vfio-pci-ids = [
		"10de:1f08"
		"10de:10f9"
		"10de:1ada"
		"10de:1adb"
	];
in {
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

    # https://wiki.nixos.org/wiki/OSX-KVM
    extraModprobeConfig = ''
      options kvm_amd nested=1
      options kvm_amd emulate_invalid_guest_state=0
      options kvm ignore_msrs=1
      options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
      blacklist nouveau
      options nouveau modeset=0
			options kvmfr static_size_mb=64
    '';

    kernelParams = [
      "psi=1" # Enable PSI to make sure that Binder doesn't die when using Waydroid.
      # "drm_kms_helper.edid_firmware=${virtualDisplayId}:edid/reboots-virtual-display.bin" # Set the custom EDID file to the virtual display interface.
			("vfio-pci.ids=" + lib.concatStringsSep "," vfio-pci-ids)
    ];

    kernelModules = [ "kvm-amd" "kvmfr" "vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd" ];
		blacklistedKernelModules = [ "nouveau" "nvidia" "nvidia_drm" "nvidia_uvm" "nvidia_modeset" "i2c_nvidia_gpu" ];
  };

  powerManagement.enable = true;

  hardware = {
    steam-hardware.enable = true;
    xone.enable = true;

    graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages = with pkgs; [
        mesa
				intel-compute-runtime
      ];
    };

    amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
    };

    opentabletdriver = {
      enable = true;
      daemon.enable = true;
    };

    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    firmware = [
      # Add the EDID of our monitors to use for the virtual display.
      (pkgs.runCommandNoCC "firmware-custom-edid" { compressFirmware = false; } ''
        mkdir -p $out/lib/firmware/edid/
        cp "${../../common/firmware/EDID.bin}" $out/lib/firmware/edid/reboots-virtual-display.bin
      '')
    ];
  };

  time.timeZone = "America/Phoenix";

  networking = {
    firewall = {
      # Open ports in the firewall.
      allowedTCPPortRanges = [ { from = 47984; to = 48010; } ];
      allowedUDPPortRanges = [ { from = 47998; to = 48010; } ];
      allowedTCPPorts = [ 3389 4455 3333 4444 50001 5567 1701 9001 4001 config.services.nix-serve.port ];
      allowedUDPPorts = [ 3389 4455 4444 50001 5567 1701 9001 4001 ];

      enable = true; # ~~false; # Or disable the firewall altogether.~~
    };
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;

    # For hibernation
    protectKernelImage = false;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    roboto
    roboto-serif
    corefonts # the msft ones, seems to not load.
  ];

  systemd.services = {
    syncthing = {
      description = "Run Syncthing";
      serviceConfig = {
        ExecStart = "${pkgs.syncthing}/bin/syncthing";
        User = "reboot";
      };
    };

    libvirtd.path = with pkgs; [
      bash
      coreutils
      pciutils # For lspci
      kmod # For modprobe
      systemd
    ];
  };

  virtualisation = {
    # Note, make sure to tell waydroid to use an AMD GPU (discrete or internal) with: https://github.com/Quackdoc/waydroid-scripts/blob/main/waydroid-choose-gpu.sh
    waydroid.enable = true;
    containers.enable = true;

    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;

      defaultNetwork.settings.dns_enabled = true;
    };

    # virtualbox.host.enable = true;
    # virtualbox.host.enableExtensionPack = true; # Requires previous, will compile all of vbox if enabled!

    libvirtd = {
      enable = true;

      qemu = {
        swtpm.enable = true;

        ovmf = {
          enable = true;
          packages = [(pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd];
        };

				verbatimConfig = ''
					cgroup_device_acl = [
				    "/dev/null", "/dev/full", "/dev/zero",
				    "/dev/random", "/dev/urandom",
				    "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
				    "/dev/rtc","/dev/hpet", "/dev/vfio/vfio",
						"/dev/kvmfr0"
					]
				'';
      };

			hooks.qemu = let
        windows-vm-name = "gayming";
      in {
        "${windows-vm-name}" = pkgs.writeShellScript windows-vm-name ''
          #!${pkgs.bash}/bin/bash
          VM_NAME="$1"
          PHASE="$2"
          STEP="$3"
          GPU_PCI_ID="0000:03:00.0"
          GPU_AUDIO_PCI_ID="0000:03:00.1"
          HOST_GFX_DRIVER="amdgpu"
          HOST_AUDIO_DRIVER="snd_hda_intel"

          if [ "$VM_NAME" = "${windows-vm-name}" ]; then
            case "$PHASE" in
              "prepare")
                case "$STEP" in
                  "begin")
                    echo "Unbinding GPU $GPU_PCI_ID and $GPU_AUDIO_PCI_ID from host drivers..."

                    echo "$GPU_PCI_ID" > /sys/bus/pci/devices/"$GPU_PCI_ID"/driver/unbind
                    echo "$GPU_AUDIO_PCI_ID" > /sys/bus/pci/devices/"$GPU_AUDIO_PCI_ID"/driver/unbind

                    echo "vfio-pci" > /sys/bus/pci/devices/"$GPU_PCI_ID"/driver_override
                    echo "vfio-pci" > /sys/bus/pci/devices/"$GPU_AUDIO_PCI_ID"/driver_override

                    echo "$GPU_PCI_ID" > /sys/bus/pci/drivers/vfio-pci/bind
                    echo "$GPU_AUDIO_PCI_ID" > /sys/bus/pci/drivers/vfio-pci/bind

                    echo "GPU $GPU_PCI_ID and $GPU_AUDIO_PCI_ID bound to vfio-pci."
                    ;;
                esac
                ;;
              "release")
                case "$STEP" in
                  "end")
                    echo "Rebinding GPU $GPU_PCI_ID and $GPU_AUDIO_PCI_ID to host drivers..."

                    echo "$GPU_PCI_ID" > /sys/bus/pci/drivers/vfio-pci/unbind
                    echo "$GPU_AUDIO_PCI_ID" > /sys/bus/pci/drivers/vfio-pci/unbind

                    echo "$HOST_GFX_DRIVER" > /sys/bus/pci/devices/"$GPU_PCI_ID"/driver_override
                    echo "$HOST_AUDIO_DRIVER" > /sys/bus/pci/devices/"$GPU_AUDIO_PCI_ID"/driver_override

                    echo "$GPU_PCI_ID" > /sys/bus/pci/drivers/"$HOST_GFX_DRIVER"/bind

                    if [ $? -ne 0 ]; then
                      echo "Failed to bind to $HOST_AUDIO_DRIVER. You might need to manually rebind."
                    else
                      echo "GPU $GPU_AUDIO_PCI_ID rebound to $HOST_AUDIO_DRIVER."
                    fi

                    echo "$GPU_AUDIO_PCI_ID" > /sys/bus/pci/drivers/"$HOST_AUDIO_DRIVER"/bind

                    if [ $? -ne 0 ]; then
                      echo "Failed to bind to $HOST_GFX_DRIVER. You might need to manually rebind."
                    else
                      echo "GPU $GPU_PCI_ID rebound to $HOST_GFX_DRIVER."
                    fi
                    ;;
                esac
                ;;
            esac
          fi
        '';
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

    gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-qt; # HHHHHHH this is such a bitch and cmd-line fallbacks don't work.
      enableSSHSupport = true;
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

		nix-serve = {
			enable = true;
			secretKeyFile = "/var/secrets/cache-private-key.pem";
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

    udev = {
      packages = with pkgs; [
        qmk-udev-rules
        android-udev-rules
      ];

			extraRules = ''
				SUBSYSTEM=="kvmfr", OWNER="reboot", GROUP="kvm", MODE="0660"
			'';
    };

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
      capSysAdmin = true;

      applications = {
        apps = [
          {
            name = "1080p Desktop";
            prep-cmd = [
              {
                # Runs:
                #   ${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor -o | ${pkgs.gnused}/bin/sed -e 's/\x1b\[[0-9;]*m//g' | ${pkgs.gnused}/bin/sed -nE 's/^Output: [0-9]+ ([A-Za-z]+-[0-9]+) enabled connected (priority( 1))?.*$/\1\3/p' > /tmp/reboots-sunshine-display-config-backup
                # First, which saves which display is primary and all the currently enabled screens in a temp file.
                #
                # Enables and makes the virtual display the primary display.
                #
                # After that, runs:
                #   cat /tmp/reboots-sunshine-display-config-backup | sed -nE 's/^([^ ]*)( 1)?$/output.\1.disable/p' | tr '\n' ' ' | rev | cut -d' ' -f2- | rev
                # Which turns the list of enabled screens into configs that kscreen-doctor accepts.
                #
                # This is basically because I don't wanna fuck with telling nix with what display connector is primary, etc every time I change displays or whatever.
                do = ''
                  ${pkgs.bash}/bin/bash -c "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor -o | ${pkgs.gnused}/bin/sed -e 's/\x1b\[[0-9;]*m//g' | ${pkgs.gnused}/bin/sed -nE 's/^Output: [0-9]+ ([A-Za-z]+-[0-9]+) enabled connected (priority( 1))?.*$/\1\3/p' > /tmp/reboots-sunshine-display-config-backup && ${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.${virtualDisplayId}.enable output.${virtualDisplayId}.priority.1 $(${pkgs.coreutils-full}/bin/cat /tmp/reboots-sunshine-display-config-backup | ${pkgs.gnused}/bin/sed -nE 's/^([^ ]*)( 1)?$/output.\1.disable/p' | ${pkgs.coreutils-full}/bin/tr '\n' ' ' | ${pkgs.util-linux}/bin/rev | ${pkgs.coreutils-full}/bin/cut -d' ' -f2- | ${pkgs.util-linux}/bin/rev)"
                '';

                # Runs:
                #   ${pkgs.coreutils-full}/bin/cat /tmp/reboots-sunshine-display-config-backup | ${pkgs.gnused}/bin/sed -nE 's/^([^ ]*)( 1)?$/output.\1.enable/p' | ${pkgs.coreutils-full}/bin/tr '\n' ' ' | ${pkgs.util-linux}/bin/rev | ${pkgs.coreutils-full}/bin/cut -d' ' -f2- | ${pkgs.util-linux}/bin/rev
                # To re-enable all disabled displays
                #
                # And then:
                #   ${pkgs.coreutils-full}/bin/cat /tmp/reboots-sunshine-display-config-backup | ${pkgs.gnused}/bin/sed -nE 's/^([^ ]*)( 1)$/output.\1.priority.1/p'
                # To set the primary display again.
                #
                # And then turns off the virtual display.
                undo = ''
                  ${pkgs.bash}/bin/bash -c "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor $(${pkgs.coreutils-full}/bin/cat /tmp/reboots-sunshine-display-config-backup | ${pkgs.gnused}/bin/sed -nE 's/^([^ ]*)( 1)?$/output.\1.enable/p' | ${pkgs.coreutils-full}/bin/tr '\n' ' ' | ${pkgs.util-linux}/bin/rev | ${pkgs.coreutils-full}/bin/cut -d' ' -f2- | ${pkgs.util-linux}/bin/rev) $(${pkgs.coreutils-full}/bin/cat /tmp/reboots-sunshine-display-config-backup | ${pkgs.gnused}/bin/sed -nE 's/^([^ ]*)( 1)$/output.\1.priority.1/p') output.${virtualDisplayId}.disable"
                '';
              }
            ];
          }
        ];
      };
    };

    desktopManager.plasma6.enable = true;

    displayManager = {
      defaultSession = "plasma";
    };

    xserver = {
      enable = true;
      # Prefer AMD GPUs over Nvidia over the modesetting over just fbdev. (But if one of the accelerators dies, use software rendering I guess.)
      # videoDrivers = [ "amdgpu" "nvidia" "modesetting" "fbdev" ];

      xkb = {
        layout = "us";
        variant = "";
      };

      displayManager = {
        lightdm = {
          greeter.enable = true;
          greeters.gtk.enable = true;
        };
      };
    };

    # displayManager.sddm.enable = true; # Not broken anymore probably, I'm just too lazy to deal with it.
    spice-autorandr.enable = true;

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

    systemPackages = with pkgs; [
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
    ];
  };
}
