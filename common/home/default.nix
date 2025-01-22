{ hostConfig, pkgs, pkgs-stable, ... }: {
  home-manager.users."${hostConfig.username}" = {
    imports = [ ./home.nix (./configs + "/${hostConfig.systemType}.nix")];
  };
}