{ pkgs, pkgs-stable, ... }: let
  stable = with pkgs-stable; [
    # Maps
    qgis
    josm
  ];
in {
  packages = stable;
}