{
  description = "conf.d — personal Nix configuration (laptop + homelab)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    agent-of-empires.url = "github:agent-of-empires/agent-of-empires";
    # aoe tracks nixpkgs-unstable, upstream tracks nixos-unstable. Following
    # shares our revision (less duplication); if a `nix flake update` ever breaks
    # the build, drop the `follows` to test against upstream's own pin first.
    agent-of-empires.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, agent-of-empires, ... }:
    let
      system = "aarch64-darwin";
      aoe = agent-of-empires.packages.${system}.default;
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
            home-manager.extraSpecialArgs = { inherit aoe; };
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