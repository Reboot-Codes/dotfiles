{ pkgs, pkgs-unstable, ... }: {
  stable = with pkgs-stable; [
    # Maps
    qgis
    josm
  ];

  packages = stable;
}