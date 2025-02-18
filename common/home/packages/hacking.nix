{ pkgs, pkgs-stable, pwndbg, ... }: let
  unstable = with pkgs; [
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
    cryptomator
    gephi
    xxd
    hexcurse
    (lib.hiPrio autopsy)
    sleuthkit
    exiftool
    samba4
    smbnetfs
    gdb
  ];

  stable = with pkgs-stable; [
    # Hacking
    rizin
    rizinPlugins.rz-ghidra
    cutter
    cutterPlugins.sigdb
    cutterPlugins.jsdec
  ];

  pwndbg-packages = let
    pkgs-pwndbg = pwndbg.packages."${pkgs.system}";
  in with pkgs-pwndbg; [
    default
    pwndbg-lldb
  ];
in {
  packages = unstable ++ stable ++ pwndbg-packages;
}
