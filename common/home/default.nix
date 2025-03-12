{ hostConfig, pkgs, pkgs-stable, pwndbg, ... }: {
  home-manager = {
    backupFileExtension = ".bak";

    users."${hostConfig.username}" = {
      imports = [
        ./home.nix
        (./configs + "/${hostConfig.systemType}.nix")
      ];
    };
  };
}
