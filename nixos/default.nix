{
  disko,
  nixpkgs,
  nixpkgs-stable,
  home-manager,
  flatpaks,
  rust-overlay,
  nur,
  chaotic,
  aagl,
  nixGL,
  pwndbg,
  nix-index-database,
  nixpkgs-xr,
  distro-grub-themes,
  sops-nix,
  ...
}:
let
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

  server = {
    username = "reboot";
    system = "x86_64-linux";
    systemType = "server";
  };

  hosts = {
    # "latitude7390-loki-nixos" = defaultDesktop;
    "custom-odin-nixos" = defaultDesktop; # // { useDisko = true; };
    "temp-installer-nixos" = installISO;

    "vps-valkyrie-edge-nixos" = server // { useDisko = true; };
  };
in
(nixpkgs.lib.genAttrs (builtins.attrNames hosts) (
  hostname:
  let
    hostConfig = hosts."${hostname}";
    system = hostConfig.system;
    isServer = hostConfig.systemType == "server";

    pkgs-stable = import nixpkgs-stable {
      # Refer to the `system` parameter from
      # the outer scope recursively
      inherit system;

      config = import ../common/utils/nix-config.nix;
    };
  in
  nixpkgs.lib.nixosSystem rec {
    system = hostConfig.system;

    # The `specialArgs` parameter passes the non-default nixpkgs instances to other nix modules
    specialArgs = {
      inherit
        pkgs-stable
        rust-overlay
        nixGL
        hostConfig
        pwndbg
        nix-index-database
        nixpkgs-xr
        distro-grub-themes
        sops-nix
        ;
    };

    modules = [
      # Imported Flakes
      home-manager.nixosModules.home-manager
      nur.modules.nixos.default
      chaotic.nixosModules.default
      nix-index-database.nixosModules.nix-index
      sops-nix.nixosModules.sops

      {
        networking.hostName = "${hostname}"; # Define your hostname.

        # AAGL stuff: https://github.com/ezKEa/aagl-gtk-on-nix (desktop/gaming only)
        imports = nixpkgs.lib.optionals (!isServer) [ aagl.nixosModules.default ];
        nix.settings = nixpkgs.lib.optionalAttrs (!isServer) aagl.nixConfig;

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;

          #! IMPORTANT: Any custom package inputs **need** to be placed here as well if they should be used by home-manager!
          extraSpecialArgs = {
            inherit
              pkgs-stable
              pwndbg
              nixpkgs-xr
              sops-nix
              hostConfig
              ;
          };
        };
      }
    ]
    ++ nixpkgs.lib.optionals (!isServer) [
      flatpaks.nixosModules.nix-flatpak
      nixpkgs-xr.nixosModules.nixpkgs-xr
    ]
    ++ [
      ../common/nixos # TODO: Set default system packages!
      ../common/home
      (./. + "/${hostname}") # Our Configs
    ]
    ++ (
      if (nixpkgs.lib.hasAttr "useDisko" hostConfig) then
        (
          if hostConfig.useDisko then
            [
              disko.nixosModules.disko
              (./. + "/${hostname}/disko.nix")
            ]
          else
            [ ]
        )
      else
        [ ]
    );
  }
))
