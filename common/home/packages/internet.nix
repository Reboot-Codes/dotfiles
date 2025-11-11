{ pkgs, pkgs-stable, ... }: let
  unstable = with pkgs; [
    firefox-devedition
    tor-browser
		brave
    onioncircuits
    # lokinet
    persepolis
    motrix
    ungoogled-chromium
    megasync
    floorp-bin
		vivaldi
  ];

  stable = with pkgs-stable; [
    onionshare-gui
  ];
in {
  packages = unstable ++ stable;
}
