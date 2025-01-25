{ disko, nixpkgs, nixpkgs-stable, home-manager, flatpaks, rust-overlay, nur, chaotic, aagl, nixGL, ... }: let
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
    "omen25l-odin-nixos" = defaultDesktop; { useDisko = true; };
    "temp-installer-nixos" = installISO;
  };
in (nixpkgs.lib.genAttrs (builtins.attrNames hosts) (hostname: let
  hostConfig = hosts."${hostname}";
  system = hostConfig.system;
  pkgs-stable = import nixpkgs-stable {
    # Refer to the `system` parameter from
    # the outer scope recursively
    inherit system;
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "electron-27.3.11" # Allows logseq stable. Annoying.
      ];
    };
  };
in nixpkgs.lib.nixosSystem rec {
  system = hostConfig.system;

  # The `specialArgs` parameter passes the non-default nixpkgs instances to other nix modules
  specialArgs = {
    inherit pkgs-stable rust-overlay nixGL hostConfig;
  };

  modules = [
    # Imported Flakes
    home-manager.nixosModules.home-manager
    flatpaks.nixosModules.declarative-flatpak
    nur.modules.nixos.default
    chaotic.nixosModules.default
    # https://github.com/ezKEa/aagl-gtk-on-nix

    {
      networking.hostName = "${hostname}"; # Define your hostname.

      # AAGL stuff.
      imports = [ aagl.nixosModules.default ];
      nix.settings = aagl.nixConfig;
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;

        extraSpecialArgs = {
          inherit pkgs-stable;
        };
      };
    }

    ../common/nixos
    ../common/home
    (./. + "/${hostname}") # Our Configs
  ] ++ (if (nixpkgs.lib.hasAttr "useDisko" hostConfig) then (if hostConfig.useDisko then [disko.nixosModules.disko (./. + "/${hostname}/disko.nix")] else []) else []);
}))