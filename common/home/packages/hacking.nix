{ pkgs, pkgs-stable, pwndbg, ... }: let
  unstable = with pkgs; [
    # Hacking (see stable)
    wireshark
    ettercap
    bettercap
    ida-free # TODO: Crack this mofo
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
    binwalk
    ltrace

    (ghidra.withExtensions (ext: with ext; [
      ret-sync
      findcrypt
      lightkeeper
      sleighdevtools
      machinelearning
      gnudisassembler
      ghidraninja-ghidra-scripts
      ghidra-delinker-extension
      ghidra-golanganalyzerextension
    ]))

    (rizin.withPlugins (ps: with ps; [ jsdec rz-ghidra sigdb ]))
    (pkgs.lib.hiPrio (cutter.withPlugins (ps: with ps; [ jsdec rz-ghidra sigdb ])))
  ];

  pwndbg-packages = let
    pkgs-pwndbg = pwndbg.packages."${pkgs.system}";
  in with pkgs-pwndbg; [
    default
    pwndbg-lldb
  ];
in {
  packages = unstable ++ pwndbg-packages;
}
