{
  unstable = [
    # Remote access (see stable)
    parsec-bin
    remmina
    moonlight-qt
    teamviewer
    anydesk
    kdePackages.krfb
  ];

  stable = [
    # Remote Access
    (lib.hiPrio rustdesk-flutter)
  ];
}