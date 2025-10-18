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
    godot_4
    android-studio
		androidStudioPackages.canary
    android-tools
    pipx
		(python313.withPackages (ps: [ ps.rpyc ps.tkinter ]))
    filezilla
    powershell
    fzf
    x11docker
    arduino
    arduino-ide
    screen
    minipro
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
		crc
		qtcreator
		kdePackages.full
		vrc-get
		alcom
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
    renpy
		unityhub
  ];
in {
  packages = unstable ++ stable;
}
