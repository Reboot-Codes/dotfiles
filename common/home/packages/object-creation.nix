{ pkgs, pkgs-stable, ... }: let
  unstable = with pkgs; [
    fritzing
    qmk
    mission-planner
    solvespace
    rpi-imager
    usbimager
    weylus
  ];

  stable = with pkgs-stable; [
    # Object creation
    kicad
    orca-slicer
    (lib.hiPrio freecad)
    # brlcad
  ];
in {
  packages = unstable ++ stable;
}