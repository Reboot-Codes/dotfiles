{ pkgs, pkgs-stable, ... }: let
  unstable = with pkgs; [
    # A/V/I (check stable)
    kdenlive
    audacity
    polyphone
    qsynth
    krita
    libresprite
    vlc
    obs-studio
    obs-studio-plugins.obs-multi-rtmp
    obs-studio-plugins.obs-mute-filter
    obs-studio-plugins.input-overlay
    obs-studio-plugins.obs-gstreamer
    obs-studio-plugins.waveform
    obs-studio-plugins.obs-3d-effect
    obs-studio-plugins.looking-glass-obs
    obs-cli
    # vital
    handbrake
    easyeffects
    imagemagickBig
    rnnoise
    rnnoise-plugin
    sdrpp
    gqrx
    cubicsdr
    amarok
    strawberry-qt6
    elisa
    drawpile
    blender
  ];

  stable = with pkgs-stable; [
    # A/V/I
    gimp-with-plugins
    lmms
    carla
  ];
in {
  packages = unstable ++ stable;
}