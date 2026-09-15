# Shared home-manager configuration (user-level) for all machines.
{ pkgs, aoe, ... }:
{
  home = {
    username = "abienkow";
    homeDirectory = "/Users/abienkow";
    stateVersion = "24.11";
    packages = with pkgs; [
      # Agent of Empires — terminal session manager for AI coding agents
      # (installed from its own flake; requires tmux, which is in base.nix).
      aoe
      # Laptop-local home packages go here (kept lean; system pkgs live in base.nix).
    ];
  };

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      # Powerlevel10k instant prompt — keep near the top of ~/.zshrc.
      initContent = ''
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
        source ~/.powerlevel10k/powerlevel10k.zsh-theme
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
        export PATH="$HOME/.local/bin:$PATH"
        [[ -r ~/.aliases ]] && source ~/.aliases
      '';
    };
git = {
      enable = true;
      settings.user.name = "Adrian Bienkowski";
      settings.user.email = "adrian@chainsafe.io";
    };
  };

  # Append (not prepend) legacy MacPorts dirs after the Nix dirs so Nix-managed
  # tools (ansible 2.18.13, nvim) take precedence. home.sessionPath prepends,
  # which would let /opt/local shadow the Nix install — hence sessionVariablesExtra.
  home.sessionVariablesExtra = ''
    export PATH="$PATH:/opt/local/bin:/opt/local/sbin"
  '';
  home.sessionVariables = { EDITOR = "nvim"; };
}
