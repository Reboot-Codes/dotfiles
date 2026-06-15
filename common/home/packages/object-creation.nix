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
    (lib.hiPrio super-slicer-latest)
    prusa-slicer
    # bambu-studio
		openrocket
		calculix-ccx

    # TODO: Remove once 2.4.0(-beta) is pushed to nixpkgs.
		(orca-slicer.override {
			glew = (glew.override {
        enableEGL = false;
      });
    })
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
