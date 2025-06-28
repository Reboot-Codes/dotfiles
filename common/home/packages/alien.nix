{ pkgs, pkgs-stable, ... }: let
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
		basiliskii
  ];

	stable = with pkgs-stable; [
		qemu_full
		qtemu
	];
in {
  packages = unstable ++ stable;
}
