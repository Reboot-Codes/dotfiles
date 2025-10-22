{ hostConfig, pkgs, pkgs-stable, pwndbg, nix-index-database, nixpkgs-xr, ... }: {
  home-manager = {
    backupFileExtension = ".bak";

    users."${hostConfig.username}" = {

      imports = [
        ./home.nix
				nix-index-database.homeModules.nix-index
        (./configs + "/${hostConfig.systemType}.nix")
      ];
    };
  };
}
