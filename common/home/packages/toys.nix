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
  ];
in {
  packages = unstable;
}
