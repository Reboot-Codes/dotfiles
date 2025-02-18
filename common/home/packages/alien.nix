{ pkgs, pkgs-stable, ... }: let
  unstable = with pkgs; [
    # Run Alien Software
    dosbox-x
    bottles
    # looking-glass-client
    distrobox
    boxbuddy
    gearlever
    simh
  ];
in {
  packages = unstable;
}
