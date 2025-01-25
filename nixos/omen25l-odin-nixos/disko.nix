{ disks ? [ "/dev/sda" "/dev/sdb" ], ... }: {
  disko.devices = {
    disk = {
      sdb = {
        type = "disk";
        device = "/dev/sdb";

        content = {
          type = "gpt";

          partitions = {
            ESP = {
              size = "5G";
              type = "EF00";

              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            KEY = {
              size = "16M";
            };

            DATA = {
              size = "100%";

              content = {
                type = "lvm_pv";
                vg = "DATA";
              };
            };
          };
        };
      };

      sda = {
        type = "disk";
        device = "/dev/sda";

        content = {
          type = "gpt";

          partitions = {
            DATA = {
              size = "100%";

              content = {
                type = "lvm_pv";
                vg = "DATA";
              };
            };
          };
        };
      };
    };

    lvm_vg = {
      DATA = {
        type = "lvm_vg";

        lvs = {
          thinpool = {
            size = "100%";
            lvm_type = "thin-pool";
          };

          NixOS = {
            size = "100%";
            lvm_type = "thinlv";
            pool = "thinpool";

            content = {
              type = "btrfs";
              extraArgs = [ "-f" ]; # Override existing partition

              # Subvolumes must set a mountpoint in order to be mounted,
              # unless their parent is mounted
              subvolumes = {
                # Subvolume name is different from mountpoint
                "/root" = {
                  mountpoint = "/";
                };

                # Subvolume name is the same as the mountpoint
                "/home" = {
                  mountOptions = [ "compress=zstd" ];
                  mountpoint = "/home";
                };

                # Parent is not mounted so the mountpoint must be set
                "/nix" = {
                  mountOptions = [ "compress=zstd" "noatime" ];
                  mountpoint = "/nix";
                };

                # Subvolume for the swapfile
                "/swap" = {
                  mountpoint = "/swap";
                  mountOptions = [ "noatime" ];
                  swap = {
                    swapfile = {
                      size = "32G";
                      path = "swapfile";
                    };
                  };
                };
              };

              swap = {
                swapfile = {
                  size = "32G";
                };
              };
            };
          };
        };
      };
    };
  };
}