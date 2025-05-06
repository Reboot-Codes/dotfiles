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
		wineWowPackages.waylandFull
		winetricks
		protontricks
		qemu_full
		qtemu
  ];
in {
  packages = unstable;
}
