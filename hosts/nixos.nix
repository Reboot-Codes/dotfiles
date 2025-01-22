{ nixpkgs, nixpkgs-stable, home-manager, flatpaks, rust-overlay, nur, chaotic, aagl, nixGL }: let
  hosts = [
    "latitude7390-loki-nixos"
  ];
in (nixpkgs.lib.genAttrs hosts (host: nixpkgs.lib.nixosSystem rec {
  system = "x86_64-linux";

  # The `specialArgs` parameter passes the non-default nixpkgs instances to other nix modules
  specialArgs = {
    # To use packages from nixpkgs-stable,
    # we configure some parameters for it first
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

    inherit rust-overlay;
    inherit nixGL;
  };

  modules = [
    # Imported Flakes
    {
      imports = [ aagl.nixosModules.default ];
      nix.settings = aagl.nixConfig;
    }
    home-manager.nixosModules.home-manager
    flatpaks.nixosModules.declarative-flatpak
    nur.modules.nixos.default
    chaotic.nixosModules.default
    # https://github.com/ezKEa/aagl-gtk-on-nix

    ./default-config.nix
    (./. + "/${host}/default.nix") # Our Configs
  ];
}))