{
  description = "conf.d — personal Nix configuration (laptop + homelab)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }:
    let
      system = "aarch64-darwin";
    in {
      darwinConfigurations."ab-macbook-m5" = nix-darwin.lib.darwinSystem {
        inherit system;
        # Per-host context, so the shared modules can branch on machine specifics.
        specialArgs = {
          host = "laptop";
          hostname = "ab-macbook-m5";
        };
        modules = [
          ./nix/base.nix
          ./nix/laptop.nix
          home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "before-nix-darwin";
            home-manager.users.abienkow = import ./nix/home.nix;
          }
        ];
      };

      # Future Linux / homelab hosts get added here as nixosConfigurations,
      # e.g. nixosConfiguration."homelab" = nixpkgs.lib.nixosSystem {
      #   system   = "x86_64-linux";
      #   specialArgs = { host = "homelab"; hostname = "…"; };
      #   modules = [ ./nix/base.nix ./nix/linux.nix home-manager.nixosModules.home-manager ];
      # };
    };
}