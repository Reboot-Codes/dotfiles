{
  unstable = [
    fritzing
    qmk
    mission-planner
    solvespace
    (lib.hiPrio freecad)
    rpi-imager
    usbimager
    weylus
  ];

  stable = [
    # Object creation
    kicad
    orca-slicer
    # brlcad
  ];
}