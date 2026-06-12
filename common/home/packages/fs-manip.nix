{ pkgs, pkgs-stable, ... }: let
  unstable = with pkgs; [
    # FS Manipulation
    btrfs-progs
    exfat
    fuzzel
    virtiofsd
    p7zip
    bchunk
  ];
in {
  packages = unstable;
}
