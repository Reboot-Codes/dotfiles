{ pkgs, pkgs-unstable, ... }: {
  unstable = with pkgs; [
    # Repair
    gparted
    ventoy-full
    idevicerestore
  ];

  packages = unstable;
}