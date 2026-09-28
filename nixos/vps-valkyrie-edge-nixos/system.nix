{ pkgs, lib, ... }: {
  boot = {
    loader = {
      grub = {
        enable = true;
        efiSupport = false;
        theme = lib.mkForce null;
      };
      efi.canTouchEfiVariables = false;
    };

    kernelParams = [ "net.ifnames=0" "biosdevname=0" ];

    kernelPackages = pkgs.linuxPackages;
    extraModulePackages = lib.mkForce [ ];

    initrd.availableKernelModules = [
      "virtio_net"
      "virtio_pci"
      "virtio_scsi"
      "virtio_blk"
      "pata_acpi"
      "ahci"
      "sd_mod"
      "sr_mod"
      "ata_piix"
      "vmw_vsock_virtio_transport"
      "vmw_vsock_virtio_transport_common"
      "vsock"
      "net_failover"
    ];
  };

  nix.settings = {
    auto-optimise-store = false;
  };

  networking = {
    networkmanager.enable = false;

    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
      "2606:4700:4700::1111"
      "2001:4860:4860::8888"
    ];

    defaultGateway = {
      address = "185.182.8.1";
      interface = "eth0";
    };

    # IPv6 Default Gateway (from `ip -6 route show default`)
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eth0";
    };

    interfaces.eth0 = {
      # Static IPv4 assignment
      ipv4 = {
        addresses = [{
          address = "185.182.9.70"; # Replace with your assigned public IPv4
          prefixLength = 24;          # Subnet mask (usually 24 or 32 on Contabo)
        }];

        routes = [{
          address = "185.182.8.1";
          prefixLength = 32;
        }];
      };

      # Static IPv6 assignment
      ipv6.addresses = [{
        address = "2a02:c207:2361:7105::1"; # Replace with your assigned IPv6
        prefixLength = 64;
      }];
    };

    firewall = {
      enable = true;
      trustedInterfaces = [ "tailscale0" ];
      allowedTCPPorts = [ 80 443 22 ];
    };
  };

  # 8GB RAM VPS swap compression to prevent OOM
  zramSwap.enable = true;
}
