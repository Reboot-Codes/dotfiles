{ pkgs, pkgs-stable, ... }: let
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
    obs-cli
    vital
    handbrake
    easyeffects
    imagemagickBig
    rnnoise
    rnnoise-plugin
    # cubicsdr
    amarok
    strawberry
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
	
	stable = with pkgs-stable; [
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
        # obs-vertical-canvas
        obs-move-transition
        obs-transition-table
        obs-3d-effect
        # obs-tuna
        obs-vaapi
        # obs-nvfbc
        obs-teleport
      ];
    })


    sdrpp
    gqrx
		lmms
		carla
	];
in {
  packages = unstable ++ stable;
}
