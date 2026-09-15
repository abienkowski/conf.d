# Shared system configuration for ALL machines (laptop + homelab).
# Both nix-darwin (macOS) and NixOS (Linux) expose `environment.systemPackages`,
# so this module is identical across hosts.
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # shell & core tooling
    bash
    zsh
    git
    gh
    curl
    wget

    # infra / automation
    ansible
    ansible-lint
    kubernetes-helm
    kubectl

    # everyday utilities
    ripgrep
    fd
    jq
    yq
    htop
    btop
    tmux
    tree
    unzip
    zip

    # data / libs
    openssl
    sqlite
    zstd
    xz
    lz4
  ];
}