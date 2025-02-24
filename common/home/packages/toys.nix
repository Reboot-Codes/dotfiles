{ pkgs, pkgs-stable, ... }: let
  unstable = with pkgs; [
    # Cool shit
    cmatrix
    cool-retro-term
    sl
    barrier
    asciicam
    asciigraph
    ascii-draw
    oneko
    emote
    glib
    protonvpn-gui
    ktailctl
  ];
in {
  packages = unstable;
}
