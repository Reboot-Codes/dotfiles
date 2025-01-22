{ pkgs, pkgs-stable, ... }: let
  unstable = with pkgs; [
    # Comms
    zoom-us
    session-desktop
    telegram-desktop
    thunderbird
    element-desktop
    discord
    signal-cli
    signalbackup-tools
    signal-export
    sigtop
    # check system flatpak config for signal desktop
  ];
in {
  packages = unstable;
}