{ hostConfig, pkgs, pkgs-stable }: {
  imports = [ ./home.nix (./configs + "/${hostConfig.systemType}.nix")];
}