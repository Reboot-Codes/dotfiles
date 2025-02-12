{ hostConfig, pkgs, pkgs-stable, pwndbg, ... }: {
  home-manager.users."${hostConfig.username}" = {
    nixpkgs.config.allowUnfree = true;

    imports = [ ./home.nix (./configs + "/${hostConfig.systemType}.nix")];
  };
}