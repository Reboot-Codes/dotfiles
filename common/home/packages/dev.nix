{ pkgs, pkgs-unstable, ... }: {
  unstable = with pkgs; [
    # Dev
    vscode
    vscodium-fhs
    (lib.hiPrio vscodium)
    zed-editor
    starship
    kate
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
    rust-bin.stable.latest.default
    pandoc
    qemu
    wimlib
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
  ];

  packages = unstable ++ stable;
}