{ pkgs, pkgs-stable, ... }: let
  unstable = with pkgs; [
    # Repair
    gparted
    ventoy-full
    man-pages
    glibcInfo
    (pkgs.lib.hiPrio stdmanpages)
    c-intro-and-ref
    tkman
    wikiman
    stdman
    texinfo
    nixpkgs-manual
    popsicle
    putty
    kdiskmark
    impression
    czkawka-full
    minipro
    minicom
    kitty
    kitty-img
    kitty-themes
		v4l-utils
		okteta
  ];

	stable = with pkgs-stable; [
    idevicerestore
		rar
	];
in {
  packages = unstable ++ stable;
}
