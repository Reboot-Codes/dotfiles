{ hostConfig, pkgs, pkgs-stable, pwndbg, ... }: {
  home-manager.users."${hostConfig.username}" = {
    imports = [
      ./home.nix
      (./configs + "/${hostConfig.systemType}.nix")
    ];
  };
}
