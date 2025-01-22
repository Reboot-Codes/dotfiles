{ pkgs, pkgs-unstable, ... }: {
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

  packages = unstable;
}