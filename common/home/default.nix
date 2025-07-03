{ hostConfig, pkgs, pkgs-stable, pwndbg, nix-index-database, ... }: {
  home-manager = {
    backupFileExtension = ".bak";

    users."${hostConfig.username}" = {

      imports = [
        ./home.nix
				nix-index-database.hmModules.nix-index
        (./configs + "/${hostConfig.systemType}.nix")
      ];
    };
  };
}
