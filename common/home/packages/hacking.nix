{ pkgs, pkgs-stable, pwndbg, ... }: let
  unstable = with pkgs; [
    # Hacking (see stable)
    wireshark
    ettercap
    bettercap
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
    pe-bear
    flare-floss
    # garble
    synchrony
    ipgrep
		cewl
		john
		hashcat-utils
		hashcat
		metasploit
		exploitdb
		sqlmap
		theharvester
		thc-hydra
		wpscan
		hcxdumptool
		wordlists
		aircrack-ng
		arp-scan

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

	stable = with pkgs-stable; [
		smbmap
		kerbrute
		bloodhound
		bloodhound-py
		enum4linux
		enum4linux-ng
		cewler
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
