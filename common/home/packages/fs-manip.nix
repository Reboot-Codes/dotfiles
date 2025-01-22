{ pkgs, pkgs-stable, ... }: let
  unstable = with pkgs; [
    # FS Manipulation
    btrfs-progs
    exfat
    fuzzel
    virtiofsd
    p7zip
    fuse-7z-ng
    bchunk
  ];
in {
  packages = unstable;
}