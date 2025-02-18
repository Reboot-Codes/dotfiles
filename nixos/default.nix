{ disko, nixpkgs, nixpkgs-stable, home-manager, flatpaks, rust-overlay, nur, chaotic, aagl, nixGL, pwndbg, ... }: let
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

  hosts = {
    "latitude7390-loki-nixos" = defaultDesktop;
    "omen25l-odin-nixos" = defaultDesktop;# // { useDisko = true; };
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
    inherit pkgs-stable rust-overlay nixGL hostConfig pwndbg;
  };

  modules = [
    # Imported Flakes
    home-manager.nixosModules.home-manager
    flatpaks.nixosModules.declarative-flatpak
    nur.modules.nixos.default
    chaotic.nixosModules.default

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

    ../common/nixos
    ../common/home
    (./. + "/${hostname}") # Our Configs
  ] ++ (if (nixpkgs.lib.hasAttr "useDisko" hostConfig) then (if hostConfig.useDisko then [disko.nixosModules.disko (./. + "/${hostname}/disko.nix")] else []) else []);
}))
