{ pkgs, pkgs-unstable, ... }: {
  unstable = with pkgs; [
    # Run Alien Software
    dosbox-x
    bottles
    looking-glass-client
    distrobox
    boxbuddy
  ];

  packages = unstable;
}