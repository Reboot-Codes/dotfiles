{ pkgs, ... }: let
  unstable = with pkgs; [
    # Run Alien Software
    dosbox-x
    bottles
    looking-glass-client
    distrobox
    boxbuddy
    gearlever
    simh
		kdePackages.kdialog
  ];
in {
  packages = unstable;
}
