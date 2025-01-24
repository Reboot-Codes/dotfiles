{ nixpkgs, nixpkgs-stable, home-manager, flatpaks, rust-overlay, nur, chaotic, aagl, nixGL, ... }: let
  defaultDesktop = {
    username = "reboot";
    system = "x86_64-linux";
    systemType = "external";
  };
in {
  "${hostConfig.username}" = let
    hostConfig = defaultDesktop;
  in home-manager.lib.homeManagerConfiguration rec {
    pkgs = nixpkgs.legacyPackages."${hostConfig.system}";
    modules = [
      ../common/home
    ];
  };
}