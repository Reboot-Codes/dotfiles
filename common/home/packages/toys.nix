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
		# input-leap
		python3Full
		python3Packages.pip
		python3Packages.srt
		python3Packages.torch
		python3Packages.openai-whisper
  ];
in {
  packages = unstable;
}
