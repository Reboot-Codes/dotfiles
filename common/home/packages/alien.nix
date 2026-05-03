{ pkgs, pkgs-stable, ... }: let
  unstable = with pkgs; [
    # Run Alien Software
    dosbox-x
    looking-glass-client
    distrobox
    boxbuddy
    gearlever
    simh
		kdePackages.kdialog
		wineWow64Packages.waylandFull
		winetricks
		protontricks
		basiliskii
  ];

	stable = with pkgs-stable; [
		qemu_full
		qtemu
    # (bottles.override { removeWarningPopup = true; })
		bottles
	];
in {
  packages = unstable ++ stable;
}
