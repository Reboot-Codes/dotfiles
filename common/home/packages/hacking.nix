{
  unstable = [
    # Hacking (see stable)
    wireshark
    ettercap
    bettercap
    ida-free # TODO: Crack this mofo
    ghidra
    ghidra-extensions.ret-sync
    # ghidra-extensions.findcrypt
    ghidra-extensions.lightkeeper
    ghidra-extensions.sleighdevtools
    ghidra-extensions.machinelearning
    ghidra-extensions.gnudisassembler
    ghidra-extensions.ghidraninja-ghidra-scripts
    ghidra-extensions.ghidra-delinker-extension
    radare2
    iaito
    veracrypt
  ];

  stable = [
    # Hacking
    rizin
    rizinPlugins.rz-ghidra
    cutter
    cutterPlugins.sigdb
    cutterPlugins.jsdec
    cryptomator
  ];
}