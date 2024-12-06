# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "vmd" "nvme" "usb_storage" "uas" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = { 
    device = "/dev/disk/by-uuid/7eb5ee9c-8a8a-470d-8005-99c7c5919b68";
    fsType = "btrfs";
    options = [ "subvol=root,compress=zstd" ];
  };

  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-uuid/7b42acb9-4902-4e0b-bc54-5b71c398964b";
    allowDiscards = true;
    keyFileSize = 4096;
    keyFile = "/dev/disk/by-id/ata-SPCC_M.2_SSD_AA000000000000000144-part2";
    fallbackToPassword = true;
  }

  fileSystems."/nix" = { 
    device = "/dev/disk/by-uuid/7eb5ee9c-8a8a-470d-8005-99c7c5919b68";
    fsType = "btrfs";
    options = [ "subvol=nix,compress=zstd,noatime" ];
  };

  fileSystems."/swap" = { 
    device = "/dev/disk/by-uuid/7eb5ee9c-8a8a-470d-8005-99c7c5919b68";
    fsType = "btrfs";
    options = [ "subvol=swap,noatime" ];
  };

  fileSystems."/boot" = { 
    device = "/dev/disk/by-uuid/0B48-E2A7";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  swapDevices = [
    "/swap/swapfile"
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.cni0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s31f6.useDHCP = lib.mkDefault true;
  # networking.interfaces.flannel.1.useDHCP = lib.mkDefault true;
  # networking.interfaces.veth0456fdfb.useDHCP = lib.mkDefault true;
  # networking.interfaces.veth35a0afbe.useDHCP = lib.mkDefault true;
  # networking.interfaces.veth39cb70bf.useDHCP = lib.mkDefault true;
  # networking.interfaces.vethdee336b8.useDHCP = lib.mkDefault true;
  # networking.interfaces.vethe7e2f709.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.ztt6jt6i65.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
