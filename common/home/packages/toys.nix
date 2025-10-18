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
		# input-leap
		python3Packages.pip
		python3Packages.srt
		python3Packages.torch
		python3Packages.openai-whisper
		kdePackages.kdeconnect-kde
		python313Packages.meshtastic
		rymdport
  ];
in {
  packages = unstable;
}
