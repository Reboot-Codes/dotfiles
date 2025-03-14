{ pkgs, pkgs-stable, ... }: let
  unstable = with pkgs; [
    # Dev
    vscode
    vscodium-fhs
    (lib.hiPrio vscodium)
    starship
    kdePackages.kate
    openldap
    openssl
    pinentry-curses
    gcc_multi
    cmake
    jdk17
    # jdk8
    deno
    gh
    act
    codeberg-cli
    codeberg-pages
    zsh
    git
    renpy
    godot_4
    android-studio
    android-tools
    pipx
    python3Full
    filezilla
    powershell
    fzf
    x11docker
    arduino
    arduino-ide
    screen
    minipro
    rust-bin.nightly.latest.default
    pandoc
    qemu
    wimlib
    scrcpy
    (lib.hiPrio kdePackages.qttools)
    d-spy
    kdePackages.yakuake
    (lib.hiPrio eclipses.eclipse-java)
    eclipses.eclipse-cpp
    eclipses.eclipse-embedcpp
    insomnia
    glade
    pods
    forge-sparks
    nixd
  ];

  stable = with pkgs-stable; [
    # Dev
    (symlinkJoin {
      name = "idea-community";
      paths = [ jetbrains.idea-community ];
      buildInputs = [ makeWrapper ];

      # stuff to make MC modding work.
      postBuild = ''
        wrapProgram $out/bin/idea-community \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [libpulseaudio libGL glfw openal stdenv.cc.cc.lib]}"
      '';
    })

    # vagrant
    (lib.hiPrio zed-editor)
  ];
in {
  packages = unstable ++ stable;
}
