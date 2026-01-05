{ pkgs, pkgs-stable, nixpkgs-xr, ... }: let
  unstable = with pkgs; [
    # Games (see stable)
		itch
    prismlauncher
    steamcmd
    steam-run
		ryubing
    dolphin-emu
    rpcs3
    ps3-disc-dumper
    ps3iso-utils
    ps3netsrv
    xemu
    the-powder-toy
    gzdoom
		qzdl
    r2modman
		# gale
    ruffle
		steamtinkerlaunch
		sidequest

    (lutris.override {
      extraLibraries = pkgs: [
        pkgs.libunwind
        gdk-pixbuf
      ];

      extraPkgs = pkgs: [
        wineWowPackages.waylandFull
      ];
    })

    mangohud
    cockatrice
    kdePackages.knetwalk
    kdePackages.kapman
    kdePackages.kolf
    kdePackages.kreversi
    superTuxKart
    # gargoyle
    # colobot
    rrootage
    # lime3ds
		# duckstation
		shadps4
  ];

  stable = with pkgs-stable; [
    # Games
    steam-tui
    openrct2
    # itchiodl
    retroarchFull
    openttd
  ];

	xr = let
    pkgs-xr = nixpkgs-xr.packages."${pkgs.stdenv.hostPlatform.system}";
  in with pkgs-xr; [
		wayvr-dashboard
  ];
in {
  packages = unstable ++ stable ++ xr;
}
