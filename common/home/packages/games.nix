{
  unstable = [
    # Games (see stable)
    prismlauncher
    steamcmd
    steam-run
    ryujinx
    dolphin-emu
    rpcs3
    ps3-disc-dumper
    ps3iso-utils
    ps3netsrv
    xemu
    the-powder-toy
    openttd
    gzdoom
    openrct2
    r2modman
    ruffle

    (lutris.override {
      extraLibraries = pkgs: [
        pkgs.libunwind
        gdk-pixbuf
      ];

      extraPkgs = pkgs: [
        # List package dependencies here
      ];
    })

    itch
    itchiodl
    mangohud
  ];

  stable = [
    # Games
    steam-tui
    retroarchFull
  ];
}