{ pkgs, pkgs-stable, ... }: let
  unstable = with pkgs; [
    fritzing
    qmk
    mission-planner
    solvespace
    (lib.hiPrio freecad)
    rpi-imager
    usbimager
    weylus
  ];

  stable = with pkgs-stable; [
    # Object creation
    kicad
    orca-slicer
    # brlcad
  ];
in {
  packages = unstable ++ stable;
}