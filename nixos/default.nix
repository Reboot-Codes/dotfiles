{ disko, nixpkgs, nixpkgs-stable, home-manager, flatpaks, rust-overlay, nur, chaotic, aagl, nixGL, pwndbg, nix-index-database, ... }: let
  defaultDesktop = {
    username = "reboot";
    system = "x86_64-linux";
    systemType = "desktop-full";
  };

  installISO = {
    username = "reboot";
    system = "x86_64-linux";
    systemType = "desktop";
  };

	# TODO: Add `server` systemType!

  hosts = {
    "latitude7390-loki-nixos" = defaultDesktop;
    "custom-odin-nixos" = defaultDesktop;# // { useDisko = true; };
    "temp-installer-nixos" = installISO;
  };
in (nixpkgs.lib.genAttrs (builtins.attrNames hosts) (hostname: let
  hostConfig = hosts."${hostname}";
  system = hostConfig.system;

  pkgs-stable = import nixpkgs-stable {
    # Refer to the `system` parameter from
    # the outer scope recursively
    inherit system;

    config = import ../common/utils/nix-config.nix;
  };
in nixpkgs.lib.nixosSystem rec {
  system = hostConfig.system;

  # The `specialArgs` parameter passes the non-default nixpkgs instances to other nix modules
  specialArgs = {
    inherit pkgs-stable rust-overlay nixGL hostConfig pwndbg nix-index-database;
  };

  modules = [
    # Imported Flakes
    home-manager.nixosModules.home-manager
    flatpaks.nixosModules.nix-flatpak
    nur.modules.nixos.default
    chaotic.nixosModules.default
		nix-index-database.nixosModules.nix-index

    {
      networking.hostName = "${hostname}"; # Define your hostname.

      # AAGL stuff: https://github.com/ezKEa/aagl-gtk-on-nix
      imports = [ aagl.nixosModules.default ];
      nix.settings = aagl.nixConfig;

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;

        #! IMPORTANT: Any custom package inputs **need** to be placed here as well if they should be used by home-manager!
        extraSpecialArgs = {
          inherit pkgs-stable pwndbg;
        };
      };
    }

    ../common/nixos # TODO: Set default system packages!
    ../common/home
    (./. + "/${hostname}") # Our Configs, TODO: Make sure that home and system packages are `//`'d together with previous configs. (Use lib.mkForce for force overrides?)
  ] ++ (if (nixpkgs.lib.hasAttr "useDisko" hostConfig) then (if hostConfig.useDisko then [disko.nixosModules.disko (./. + "/${hostname}/disko.nix")] else []) else []);
}))
