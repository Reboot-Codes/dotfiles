{ hostConfig, pkgs, pkgs-stable, ... }: {
  home-manager.users."${hostConfig.username}" = {
    nixpkgs.config.allowUnfree = true;

    imports = [ ./home.nix (./configs + "/${hostConfig.systemType}.nix")];
  };
}