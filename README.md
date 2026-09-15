# conf.d — Personal Configuration Files

Keep your terminal configuration in one place.

## Prerequisites

- **tmux** ≥ 2.1
- **git**
- **zsh** (macOS default), bash, or fish

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/abienkowski/conf.d/master/setup.sh | bash
```

Then inside tmux press `prefix` + `I` (capital I) to install tmux plugins.

## Rebuild a machine (Nix / nix-darwin)

This repo also carries the Nix configuration that installs system packages and
manages the shell across machines — see `flake.nix` and `nix/`. The goal is to
keep one config common to all hosts, with machine-specific extras in a thin
per-host module (currently `nix/laptop.nix` for this Mac).

### On a new Mac

```bash
# 1. Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh

# 2. Clone this repo and link it as the nix-darwin config
git clone git@github.com:abienkowski/conf.d.git ~/conf.d
ln -s ~/conf.d ~/.config/nix-darwin

# 3. First-time bootstrap (applies system packages, home-manager, zsh, etc.)
nix run nix-darwin -- switch --flake ~/.config/nix-darwin

# 4. Later rebuilds
darwin-rebuild switch --flake ~/.config/nix-darwin
```

<i>`nix run nix-darwin …` is used only for the very first switch; afterwards
`darwin-rebuild` is installed and on PATH (run it with `sudo` if it asks).</i>

The Nix configuration manages system packages and the shell (zsh, git identity,
editor). The dotfiles themselves — `aliases`, `tmux.conf`, `vimrc` — are still
installed by `setup.sh` on any machine, Nix or not (run it once, or install the
files manually; `~/.aliases` is sourced conditionally if present).

On a fresh machine there is **no** `/opt/local`-first PATH hack to remove — that
legacy prepend was a MacPorts artifact and is gone. MacPorts itself is still
reachable at `/opt/local/bin` (appended after the Nix dirs via
`home.sessionVariablesExtra`).

### Notes
- ansible-core is pinned to `2.18.13` in `nix/laptop.nix` (an overlay builds it
  against Python 3.13).
- `nix/` modules: `base.nix` = shared system packages, `home.nix` = shared
  home-manager config, `laptop.nix` = per-host extras.

## Manual Setup

```bash
git clone git@github.com:abienkowski/conf.d.git ~/conf.d
~/conf.d/setup.sh
```

## What the Setup Script Does

1. Downloads the config files directly from GitHub (no clone needed when using the one-liner)
2. Backs up any existing `~/.tmux.conf`, `~/.vimrc`, `~/.aliases` by renaming them in-place (e.g. `.tmux.conf` → `.tmux.conf-YYYY-MM-DD`). If a backup already exists for today, it's preserved and not overwritten.
3. Copies the repo's config files into `$HOME`
4. Clones [TPM](https://github.com/tmux-plugins/tpm) to `~/.tmux/plugins/tpm`
5. Adds `source ~/.aliases` to your shell's rc file (`~/.zshrc`, `~/.bashrc`, etc.)
6. Prints post-install steps

The script is **idempotent** — running it again is safe.

## Tmux Key Bindings

| Binding | Action |
|---|---|
| `C-a` | Prefix (instead of default `C-b`) |
| `C-a C-a` | Send prefix to nested tmux session |
| `C-b` | Jump to last window |
| `prefix` `r` | Reload `~/.tmux.conf` |
| `prefix` `|` | Split pane horizontally |
| `prefix` `-` | Split pane vertically |
| `prefix` `T` | Swap current window to position 1 |
| `prefix` `C-a` | Cycle to next pane |
| `prefix` `h/j/k/l` | Select pane left/down/up/right (vim-style) |
| `prefix` `I` | Install TPM plugins |
| `prefix` `U` | Update TPM plugins |
| `prefix` `M-u` | Clean uninstalled TPM plugins |

Other settings:
- Mouse mode on, scrollback 10k lines, vi-style copy-mode
- Window numbering starts at 1
- Active window highlighted with cyan background

## Aliases

| Alias | Expands To |
|---|---|
| `ll` | `ls -laF` |
| `k` | `kubectl` (resolved at install time) |
| `kns` | `kubens` (resolved at install time) |

## Customizing

Edit the files in `~/conf.d/` then re-run the setup script to apply changes. If you want shell-specific aliases that aren't shared across machines, add them directly to your `~/.zshrc` (or equivalent) instead of editing `~/conf.d/aliases`.

## Uninstall

```bash
# Remove installed files
rm ~/.tmux.conf
rm ~/.vimrc
rm ~/.aliases

# Remove TPM
rm -rf ~/.tmux/plugins/tpm

# Remove source line from shell rc (use your shell's rc: ~/.bashrc, ~/.config/fish/config.fish)
sed -i '' '/^source.*\/\.aliases/d' ~/.zshrc
```

## Updating

If you used the one-liner, re-run it:

```bash
curl -fsSL https://raw.githubusercontent.com/abienkowski/conf.d/master/setup.sh | bash
```

If you cloned the repo, pull and re-run:

```bash
cd ~/conf.d && git pull && ./setup.sh
```

The script is idempotent — it will skip files that haven't changed. After a tmux config update, reload with `prefix` `r`.
