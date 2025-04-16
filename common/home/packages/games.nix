{ pkgs, pkgs-stable, ... }: let
  unstable = with pkgs; [
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
    gzdoom
    openrct2
    r2modman
		gale
    ruffle

    (lutris.override {
      extraLibraries = pkgs: [
        pkgs.libunwind
        gdk-pixbuf
      ];

      extraPkgs = pkgs: [
        wineWowPackages.waylandFull
      ];
    })

    itch
    itchiodl
    mangohud
    cockatrice
    kdePackages.knetwalk
    kdePackages.kapman
    kdePackages.kolf
    kdePackages.kreversi
    superTuxKart
    gargoyle
    # colobot
    rrootage
    # lime3ds
    duckstation
		shadps4
  ];

  stable = with pkgs-stable; [
    # Games
    steam-tui
    retroarchFull
    openttd
  ];
in {
  packages = unstable ++ stable;
}
