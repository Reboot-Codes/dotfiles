{ pkgs, ... }: let
  unstable = with pkgs; [
    # A/V/I (check stable)
    kdePackages.kdenlive
		glaxnimate
    audacity
    polyphone
    qsynth
    krita
    libresprite
    vlc
		openutau

    (pkgs.wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
        obs-multi-rtmp
        obs-mute-filter
        input-overlay
        obs-gstreamer
        waveform
        obs-3d-effect
        looking-glass-obs
        obs-vkcapture
        obs-shaderfilter
        obs-source-record
        # obs-replay-source
        obs-freeze-filter
        obs-vintage-filter
        obs-composite-blur
        obs-command-source
        obs-vertical-canvas
        obs-move-transition
        obs-transition-table
        obs-3d-effect
        obs-tuna
        obs-vaapi
        # obs-nvfbc
        obs-teleport
        obs-webkitgtk
      ];
    })

    obs-cli
    vital
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
    kdePackages.elisa
    drawpile
    blender
    lunacy
    blockbench
    # fooyin
    furnace
    helvum
    musescore
    muse-sounds-manager
    blanket
    qsstv
    inkscape-with-extensions
    gimp-with-plugins
    lmms
    carla
    shortwave
    quodlibet-full
    # natron
    nuclear
    losslesscut-bin
    # sooperlooper
    fretboard
    livecaptions
    pulseeffects-legacy
    polyphone
    # mandelbulber
  ];
in {
  packages = unstable;
}
