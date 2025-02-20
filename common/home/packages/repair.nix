{ pkgs, pkgs-stable, ... }: let
  unstable = with pkgs; [
    # Repair
    gparted
    ventoy-full
    idevicerestore
    man-pages
    glibcInfo
    (pkgs.lib.hiPrio stdmanpages)
    c-intro-and-ref
    tkman
    wikiman
    stdman
    texinfo
    nixpkgs-manual
  ];
in {
  packages = unstable;
}
