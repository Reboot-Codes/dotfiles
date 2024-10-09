{
  description = "Main flake for all workstations managed by Reboot/Fitz.";

  # Enable the community cachix to build less stuff
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flatpaks.url = "github:GermanBread/declarative-flatpak/stable-v3";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = github:nix-community/NUR;
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, flatpaks, rust-overlay, nur, chaotic, aagl }: {
    nixosConfigurations = {
      "ressd-loki-nixos" = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";

	      # The `specialArgs` parameter passes the
        # non-default nixpkgs instances to other nix modules
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
        };

        modules = [
	        # Imported Flakes
          home-manager.nixosModules.home-manager
          flatpaks.nixosModules.default
          nur.nixosModules.nur
          chaotic.nixosModules.default
          # https://github.com/ezKEa/aagl-gtk-on-nix
          {
            imports = [ aagl.nixosModules.default ];
            nix.settings = aagl.nixConfig; # Set up Cachix

            programs = {
              anime-game-launcher.enable = true; # Adds launcher and /etc/hosts rules
              anime-games-launcher.enable = true;
              honkers-railway-launcher.enable = true;
              honkers-launcher.enable = true;
              wavey-launcher.enable = true;
              sleepy-launcher.enable = true;
            };
          }
          
          # My configurations.
          ./hosts/ressd-loki-nixos/default.nix # System specific system-level and user-level configurations.
          ./common/home.nix # Global homedir config
        ];
      };
    };
  };
}
