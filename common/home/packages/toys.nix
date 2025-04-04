{ pkgs, pkgs-stable, ... }: let
  unstable = with pkgs; [
    # Cool shit
    cmatrix
    cool-retro-term
    sl
    asciicam
    asciigraph
    ascii-draw
    oneko
    emote
    glib
    protonvpn-gui
    ktailctl
    kdePackages.wallpaper-engine-plugin
    lightly-qt
		input-leap
  ];
in {
  packages = unstable;
}
