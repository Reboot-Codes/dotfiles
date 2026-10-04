{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "thunderbolt"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "vmd"
    "nvme"
    "uas"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-uuid/87e29a50-5620-4e91-b158-3be0dc890db1";
    allowDiscards = true;
    keyFileSize = 4096;
    keyFile = "/dev/disk/by-partuuid/6c3b0218-edb2-4740-9c15-482667f229d8";
    keyFileTimeout = 5;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/82862926-048f-4b62-a7e1-df224cae1d73";
      fsType = "btrfs";

      options = [
        "subvol=root"
        "compress=zstd"
        "noatime"
      ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/04BA-15B1";
      fsType = "vfat";

      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };

    "/home" = {
      device = "/dev/disk/by-uuid/82862926-048f-4b62-a7e1-df224cae1d73";
      fsType = "btrfs";

      options = [
        "subvol=home"
        "compress=zstd"
        "noatime"
      ];
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/82862926-048f-4b62-a7e1-df224cae1d73";
      fsType = "btrfs";

      options = [
        "subvol=nix"
        "compress=zstd"
        "noatime"
      ];
    };

    "/swap" = {
      device = "/dev/disk/by-uuid/82862926-048f-4b62-a7e1-df224cae1d73";
      fsType = "btrfs";

      options = [
        "subvol=swap"
        "noatime"
      ];
    };

    "/data/bulk" = {
      device = "/dev/disk/by-uuid/b8a34075-b8c6-4e85-a9a5-ead53ab5bb3a";
      fsType = "btrfs";

      options = [
        "subvol=@bulk"
        "compress=zstd"
        "noatime"
        "nofail"
      ];
    };

    "/data/bulk/vms" = {
      device = "/dev/disk/by-uuid/b8a34075-b8c6-4e85-a9a5-ead53ab5bb3a";
      fsType = "btrfs";

      options = [
        "subvol=@vms"
        "nodatacow"
        "noatime"
        "nofail"
      ];
    };

    "/data/bulk/backups" = {
      device = "/dev/disk/by-uuid/b8a34075-b8c6-4e85-a9a5-ead53ab5bb3a";
      fsType = "btrfs";

      options = [
        "subvol=@backups"
        "compress=zstd"
        "noatime"
        "nofail"
      ];
    };

    "/data/ZimaOS" = {
      device = "//192.168.8.190/ZimaOS-HD";
      fsType = "cifs";

      options = [
        "credentials=/run/secrets/logins/servers/zimaos/cifs"
        "vers=3.0"
        "_netdev"
        "nofail"
        "uid=1000"
        "gid=1000"
      ];
    };

    "/srv/win11/pipewire-0" = {
      device = "/run/user/1000/pipewire-0";
      fsType = "none";

      options = [
        "bind"
        "rw"
        "user"
        "noauto"
      ];
    };
  };

  swapDevices = [
    { device = "/swap/swapfile"; }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
