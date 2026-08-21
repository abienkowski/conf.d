# Laptop-specific (macOS / nix-darwin) configuration.
# Everything in here is extra to `base.nix` and specific to this machine.
{ pkgs, host, hostname, ... }:
{
  programs.zsh.enable = true;
  nix.enable = true;
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = 7;

  # home-manager's nixos integration derives homeDirectory from here.
  users.users.abienkow = {
    name = "abienkow";
    home = "/Users/abienkow";
  };

  # Pin ansible-core to 2.18.13.
  # nixpkgs ships ansible-core 2.21.x built on Python 3.14, but 2.18.x only
  # officially supports <=3.13, so the override builds against python313Packages.
  #
  # The override touches `python313Packages.ansible-core` itself (not just the
  # wrapped `ansible` app) so that everything deriving from that package set —
  # including `ansible-lint`'s bundled ansible-core module — stays consistent
  # with the `ansible` binary on PATH. Without this, ansible-lint would import
  # nixpkgs' default ansible-core (~2.21.x) while shelling out to 2.18.13,
  # reproducing the same "CLI and python module do not match" mismatch.
  nixpkgs.overlays = [
    (final: prev: {
      python313Packages = prev.python313Packages.override {
        overrides = pyFinal: pyPrev: {
          ansible-core = pyPrev.ansible-core.overrideAttrs (old: {
            version = "2.18.13";
            src = final.fetchFromGitHub {
              owner = "ansible";
              repo = "ansible";
              tag = "v2.18.13";
              hash = "sha256-RtJCj9BOT/s5PNA3UshFw9hy+TNI6XkY+QeIFU3PiM0=";
            };
            # Drop the circular `ansible` meta-dependency so the shell only
            # gets the ansible-core CLI binaries.
            dependencies = final.lib.remove pyPrev.ansible (old.dependencies or [ ]);
          });
        };
      };

      ansible = final.python313Packages.toPythonApplication final.python313Packages.ansible-core;

      # Rebuild ansible-lint against the same python313Packages set so its
      # bundled ansible-core module matches the `ansible` binary it wraps.
      ansible-lint = final.callPackage "${final.path}/pkgs/by-name/an/ansible-lint/package.nix" {
        python3Packages = final.python313Packages;
        inherit (final) ansible;
      };
    })
  ];

  environment.systemPackages = with pkgs; [
    neovim
    _1password-cli
    tree-sitter
    nodejs_22
    python314
    pre-commit
  ];
}