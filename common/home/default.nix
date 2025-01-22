{ installType, pkgs, pkgs-stable }: {
  imports = [ ./home.nix (./. + "/configs/${installType}.nix") ];
}