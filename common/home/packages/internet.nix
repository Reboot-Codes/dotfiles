{ pkgs, pkgs-stable, ... }: let
  unstable = with pkgs; [
    # firefox-devedition
    tor-browser-bundle-bin
    brave
    onioncircuits
    lokinet
    persepolis
    motrix
    ungoogled-chromium
    megasync
    floorp
		vivaldi
  ];

  stable = with pkgs-stable; [
    onionshare-gui
  ];
in {
  packages = unstable ++ stable;
}
