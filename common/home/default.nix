{ hostConfig, pkgs, pkgs-stable, pwndbg, nix-doom-emacs, ... }: {
  home-manager.users."${hostConfig.username}" = {
    imports = [ ./home.nix (./configs + "/${hostConfig.systemType}.nix") nix-doom-emacs.hmModule ];
  };
}
