{ pkgs, pkgs-stable, ... }: let
  unstable = with pkgs; [
    # Repair
    gparted
    ventoy-full
    idevicerestore
  ];
in {
  packages = unstable;
}