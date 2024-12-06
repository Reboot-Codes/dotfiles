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

    flatpaks = { 
      url = "github:GermanBread/declarative-flatpak/stable-v3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    nixGL = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, flatpaks, rust-overlay, nur, chaotic, aagl, nixGL }: {
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
          inherit nixGL;
        };

        modules = [
	        # Imported Flakes
          {
            nixpkgs.overlays = [
              nixGL.overlays.default
            ];
          }
          home-manager.nixosModules.home-manager
          flatpaks.nixosModules.declarative-flatpak
          nur.nixosModules.nur
          chaotic.nixosModules.default
          # https://github.com/ezKEa/aagl-gtk-on-nix
          {
            imports = [ aagl.nixosModules.default ];
            nix.settings = aagl.nixConfig; # Set up Cachix
          }
          
          ./hosts/ressd-loki-nixos/default.nix # Our Configs
        ];
      };

      "latitude7390-loki-nixos" = nixpkgs.lib.nixosSystem rec {
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
          inherit nixGL;
        };

        modules = [
	        # Imported Flakes
          {
            nixpkgs.overlays = [
              nixGL.overlays.default
            ];
          }
          home-manager.nixosModules.home-manager
          flatpaks.nixosModules.declarative-flatpak
          nur.nixosModules.nur
          chaotic.nixosModules.default
          # https://github.com/ezKEa/aagl-gtk-on-nix
          {
            imports = [ aagl.nixosModules.default ];
            nix.settings = aagl.nixConfig; # Set up Cachix
          }
          
          ./hosts/latitude7390-loki-nixos/default.nix # Our Configs
        ];
      };
    };

    # For *nix systems that are not NixOS or macOS
    homeConfigurations = {
      "reboot" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        modules = [ ./hosts/generic-amd64-linux-gui/default.nix ];
      };
    };
  };
}
