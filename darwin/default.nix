{
  nix-darwin,
  nixpkgs,
  nixpkgs-stable,
  home-manager,
  rust-overlay,
  pwndbg,
  nix-index-database,
  sops-nix,
  ...
}:
let
  defaultDesktop = {
    username = "reboot";
    system = "aarch64-darwin";
    systemType = "darwin-full";
  };

  hosts = {
    "mba15-thor-osx" = defaultDesktop;
  };
in
(nixpkgs.lib.genAttrs (builtins.attrNames hosts) (
  hostname:
  let
    hostConfig = hosts."${hostname}";
    system = hostConfig.system;

    pkgs-stable = import nixpkgs-stable {
      # Refer to the `system` parameter from
      # the outer scope recursively
      inherit system;

      config = import ../common/utils/nix-config.nix;
    };
  in
  nix-darwin.lib.darwinSystem rec {
    system = hostConfig.system;

    # The `specialArgs` parameter passes the non-default nixpkgs instances to other nix modules
    specialArgs = {
      inherit
        pkgs-stable
        rust-overlay
        hostConfig
        pwndbg
        nix-index-database
        sops-nix
        nix-darwin
        ;
    };

    modules = [
      # Imported Flakes
      home-manager.darwinModules.home-manager

      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;

          #! IMPORTANT: Any custom package inputs **need** to be placed here as well if they should be used by home-manager!
          extraSpecialArgs = {
            inherit
              pkgs-stable
              pwndbg
              sops-nix
              nix-darwin
              ;
          };
        };
      }

      ../common/darwin # TODO: Set default system packages!
      ../common/home
      (./. + "/${hostname}") # Our Configs, TODO: Make sure that home and system packages are `//`'d together with previous configs. (Use lib.mkForce for force overrides?)
    ];
  }
))
