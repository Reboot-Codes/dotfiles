{ pkgs, pkgs-stable, ... }: let
  unstable = with pkgs; [
		(lib.hiPrio freecad)
    fritzing
    qmk
    mission-planner
    solvespace
    # rpi-imager
    usbimager
    weylus
    librecad
    orca-slicer
    (lib.hiPrio super-slicer-latest)
    prusa-slicer
    # bambu-studio
		openrocket
		calculix-ccx
  ];

  stable = with pkgs-stable; [
    # Object creation
    kicad
		openscad
    # brlcad
  ];
in {
  packages = unstable ++ stable;
}
