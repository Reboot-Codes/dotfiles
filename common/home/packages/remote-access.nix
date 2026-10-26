{ pkgs, ... }: let
  unstable = with pkgs; [
    # Remote access
    parsec-bin
    remmina
    moonlight-qt
    teamviewer
    anydesk
    kdePackages.krfb
		omnissa-horizon-client
		waypipe
		syncthingtray
		(lib.hiPrio rustdesk-flutter)
  ];
in {
  packages = unstable;
}
