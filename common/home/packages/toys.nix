{ pkgs, pkgs-unstable, ... }: {
  unstable = with pkgs; [
    # Cool shit
    cmatrix
    cool-retro-term
    sl
  ];

  packages = unstable;
}