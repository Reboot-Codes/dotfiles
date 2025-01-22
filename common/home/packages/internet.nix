{ pkgs, pkgs-unstable, ... }: {
  unstable = with pkgs; [
    firefox-devedition
    tor-browser-bundle-bin
    brave
    onioncircuits
    lokinet
    persepolis
    motrix
    ungoogled-chromium
    megasync
  ];

  stable = with pkgs-stable; [
    onionshare-gui
  ];

  packages = unstable ++ stable;
}