{ pkgs, pkgs-stable, ... }: let
  unstable = with pkgs; [
    # Remote access (see stable)
    parsec-bin
    remmina
    moonlight-qt
    teamviewer
    anydesk
    kdePackages.krfb
  ];

  stable = with pkgs-stable; [
    # Remote Access
    (lib.hiPrio rustdesk-flutter)
  ];
in {
  packages = unstable ++ stable;
}