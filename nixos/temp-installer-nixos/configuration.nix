{ pkgs, config, modulesPath, hostConfig, ... }: {
  imports = [(modulesPath + "/installer/cd-dvd/installation-cd-base.nix")];

  users.users."${hostConfig.username}".password = "password";
  boot.plymouth.enable = true;

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true; # For steam specifically, but will be for all of opengl...

      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        libvdpau-va-gl
        mesa.drivers
        intel-media-sdk
        vpl-gpu-rt
      ];
    };

    #nvidia = {
    #  modesetting.enable = true;
    #  powerManagement.enable = false;
    #  open = false;
    #  powerManagement.finegrained = false;
    #  nvidiaSettings = true;
    #  package = config.boot.kernelPackages.nvidiaPackages.stable;
    #};

    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    roboto
    roboto-serif
    corefonts # the msft ones, seems to not load.
  ];

  programs = {
    neovim = {
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
    };

    xwayland.enable = true;
  };

  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    desktopManager.plasma6.enable = true;
    displayManager.defaultSession = "plasma";

    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];

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
  };

  environment.systemPackages = with pkgs; [
    neovim
    tmux
    busybox
    eza
    fastfetch
    fortune
    lolcat
    btop
    btop
    firefox
    screen
    git
    curl
    wget
    zsh
    bash
    wl-clipboard
    gnupg
    libnotify
    appimage-run
    xorg.xhost
    alsa-utils
    pciutils
    dmidecode
    usbutils
    libva-utils
    pmutils
    refind
    efibootmgr
    smartmontools
    nmap
    socat
    openssl
    speedtest-cli
    zed-editor
    vscodium
    btrfs-progs
    btrbk
    fuzzel
    sshfs
    exfat
    ntfs3g
    mtpfs
    links2
    alacritty
    qpwgraph
    mpv
    imagemagickBig
    ffmpeg
    zerotierone
    syncthing
    kdePackages.breeze
    kdePackages.breeze-gtk
    gparted
  ];
}
