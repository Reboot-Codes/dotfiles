{
  description = "Main flake for all workstations managed by Reboot/Fitz.";

  # Enable the community cachix to build less stuff
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://pwndbg.cachix.org"
			"http://custom-odin-nixos.tail90c5.ts.net:5000"
    ];

    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "pwndbg.cachix.org-1:HhtIpP7j73SnuzLgobqqa8LVTng5Qi36sQtNt79cD3k="
			"custom-odin-nixos.tail90c5.ts.net:4HayvfsG++iTVCjRk4OtrrKwvLJhwFpKE84RrKOCej4="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flatpaks.url = "github:gmodena/nix-flatpak/?ref=latest";

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

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pwndbg = {
      url = "github:pwndbg/pwndbg";
      inputs.nixpkgs.follows = "nixpkgs";
    };

		nix-index-database = {
			url = "github:nix-community/nix-index-database";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, flatpaks, rust-overlay, nur, chaotic, aagl, nixGL, disko, pwndbg, nix-index-database, nixpkgs-xr }: {
    nixosConfigurations = import ./nixos {
      inherit nixpkgs nixpkgs-stable home-manager flatpaks rust-overlay nur chaotic aagl nixGL disko pwndbg nix-index-database nixpkgs-xr;
    };

    # For *nix systems that are not NixOS or macOS
    homeConfigurations = import ./home-manager.nix {
      inherit nixpkgs nixpkgs-stable home-manager flatpaks rust-overlay nur chaotic aagl nixGL pwndbg nix-index-database nixpkgs-xr;
    };
  };
}
