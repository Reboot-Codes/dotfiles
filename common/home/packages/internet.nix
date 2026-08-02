{ pkgs, pkgs-stable, ... }:
let
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
    librewolf
    ladybird
  ];

  stable = with pkgs-stable; [
    onionshare-gui
  ];
in
{
  packages = unstable ++ stable;
}
