# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, pkgs-stable, lib, ... }: {
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
			options kvmfr static_size_mb=64
    '';

    kernelParams = [
      "psi=1" # Enable PSI to make sure that Binder doesn't die when using Waydroid.
      # "drm_kms_helper.edid_firmware=${virtualDisplayId}:edid/reboots-virtual-display.bin" # Set the custom EDID file to the virtual display interface.
			("vfio-pci.ids=" + lib.concatStringsSep "," vfio-pci-ids)
    ];

    kernelModules = [ "kvm-amd" "kvmfr" "vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd" ];

		binfmt = {
			emulatedSystems = [
				"armv6l-linux"
				"armv7l-linux"
				"aarch64-linux"
				"aarch64_be-linux"
				"alpha-linux"
				"sparc64-linux"
				"sparc-linux"
				"powerpc-linux"
				"powerpc64-linux"
				"powerpc64le-linux"
				"mips-linux"
				"mipsel-linux"
				"mips64-linux"
				"mips64el-linux"
				"mips64-linuxabin32"
				"mips64el-linuxabin32"
				"riscv32-linux"
				"riscv64-linux"
				"loongarch64-linux"
				"wasm32-wasi"
				"wasm64-wasi"
				"s390x-linux"
			];
		};
  };

  powerManagement.enable = true;

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages = with pkgs; [
        mesa
				intel-compute-runtime
      ];
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
		# bridges."rebootvmbr0".interfaces = [ "enp13s0" ];

    firewall = {
      # Open ports in the firewall.
      allowedUDPPorts = [ 4001 ];
      allowedTCPPorts = [ 4001 config.services.nix-serve.port ];

      enable = true;
    };
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;

    # For hibernation
    protectKernelImage = false;

		# https://discourse.nixos.org/t/distrobox-selinux-oci-permission-error/64943/15 ; TL;DR: distrobox mounted the empty SELinux directory when my containers were created, and the SELinux module isn't ready yet, so this is a temp fix due to this pull existing: https://github.com/NixOS/nixpkgs/pull/407748
		lsm = lib.mkForce [ ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    roboto
    roboto-serif
    corefonts # the msft ones, seems to not load.
		noto-fonts-cjk-sans
		noto-fonts-cjk-serif
  ];

  systemd = {
		tmpfiles.rules = [
			"f /srv/win11/pipewire-0 700 reboot reboot - -"
		];

		timers = {
			nix-clean = {
				wantedBy = [ "timers.target" ];

				timerConfig = {
					OnUnitActiveSec = "1w";
					Unit = "nix-clean.service";
				};
			};
		};

		services = {
			syncthing = {
				description = "Run Syncthing";
				serviceConfig = {
					ExecStart = "${pkgs.syncthing}/bin/syncthing";
					User = "reboot";
				};
			};

			nix-clean = {
				script = ''
					${pkgs.nix}/bin/nix-store --gc
				'';

				serviceConfig = {
					Type = "oneshot";
					User = "root";
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
	};

  virtualisation = {
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
				# Fucking.... ceph... also. so sorry y'all at nixpkgs, noob momence go brr.
				package = pkgs-stable.qemu;

        swtpm.enable = true;

        ovmf = {
          enable = true;
          packages = [(pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd];
        };

				verbatimConfig = ''
					user = "reboot"

					cgroup_device_acl = [
				    "/dev/null", "/dev/full", "/dev/zero",
				    "/dev/random", "/dev/urandom",
				    "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
				    "/dev/rtc","/dev/hpet", "/dev/vfio/vfio",
						"/dev/kvmfr0", "/run/user/1000/pipewire-0"
					]
				'';
      };
    };

    appvm = {
      enable = true;
      user = "reboot";
    };

    spiceUSBRedirection.enable = true;

    oci-containers = {
      backend = "podman";
      containers = { 
        homeassistant = {
          volumes = [ "/opt/home-assistant:/config" ];
          environment.TZ = "America/Phoenix";
          image = "ghcr.io/home-assistant/home-assistant:stable";
          extraOptions = [ 
            "--network=host" 
            # "--device=/dev/ttyACM0:/dev/ttyACM0"
          ];
        };
      };
    };
  };

  programs = {
    neovim = {
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
    };

    adb.enable = true;
    virt-manager.enable = true;
    nbd.enable = true;
    xwayland.enable = true;
    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # mtr.enable = true;

    dconf.enable = true;

		java = {
			binfmt = true;
			enable = true;
		};
  };

  xdg.portal = {
    enable = true;

    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
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
			# enable = true;
			secretKeyFile = "/var/secrets/cache-private-key.pem";
		};

    zerotierone = {
      enable = true;

      joinNetworks = [
        "56374ac9a475ea79"
      ];
    };

    pulseaudio.enable = false; # This is a pipewire-based system!

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
				SUBSYSTEM=="usb", MODE="0660", GROUP="wheel"
			'';
    };

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

    desktopManager.plasma6.enable = true;

    displayManager = {
      defaultSession = "plasma";
    };

    xserver = {
      enable = true;

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
        "com.github.tchx84.Flatseal"
        "org.signal.Signal"
        "io.github.hydrusnetwork.hydrus"
      ];
    };

    cockpit = {
      enable = true;
      port = 9090;
      openFirewall = true; # Please see the comments section
      settings = {
        WebService = {
          AllowUnencrypted = true;
        };
      };
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
      cockpit

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
      zerotierone
      syncthing
      nicotine-plus

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
    ]) ++ (with pkgs-stable; [
			qemu_full
		]);
  };
}
