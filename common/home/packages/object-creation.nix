{ pkgs, pkgs-stable, ... }: let
  unstable = with pkgs; [
    fritzing
    qmk
    mission-planner
    solvespace
    rpi-imager
    usbimager
    weylus
    librecad
    orca-slicer
    (lib.hiPrio super-slicer-latest)
    prusa-slicer
    bambu-studio
		openrocket
  ];

  stable = with pkgs-stable; [
    # Object creation
    kicad
    (lib.hiPrio freecad)
    # brlcad
  ];
in {
  packages = unstable ++ stable;
}
