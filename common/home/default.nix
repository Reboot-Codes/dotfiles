{ installType }: {
  imports = [ ./home.nix (./. + "/configs/${installType}.nix") ];
}