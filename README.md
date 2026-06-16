# conf.d — Personal Configuration Files

Tmux, (neo)vim, and shell aliases — managed in one repo so a new laptop is minutes away from feeling like home.

## Prerequisites

- **tmux** ≥ 2.1 (`brew install tmux`)
- **git**
- **zsh** (macOS default), bash, or fish

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/abienkowski/conf.d/main/setup.sh | bash
```

Then inside tmux press `prefix` + `I` (capital I) to install tmux plugins.

## Manual Setup

```bash
git clone git@github.com:abienkowski/conf.d.git ~/conf.d
~/conf.d/setup.sh
```

## What the Setup Script Does

1. Clones the repo (if run via curl-pipe) into `~/conf.d`
2. Backs up any existing `~/.tmux.conf`, `~/.vimrc`, `~/.aliases` by renaming them in-place (e.g. `.tmux.conf` → `.tmux.conf-2026-06-16`)
3. Symlinks the repo's config files into `$HOME`
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

Edit the files in `~/conf.d/` and the symlinks will pick up the changes automatically. If you want shell-specific aliases that aren't shared across machines, add them directly to your `~/.zshrc` (or equivalent) instead of editing `~/conf.d/aliases`.

## Uninstall

```bash
# Remove symlinks
unlink ~/.tmux.conf
unlink ~/.vimrc
unlink ~/.aliases

# Remove TPM
rm -rf ~/.tmux/plugins/tpm

# Remove source line from shell rc
sed -i '' '/^source.*\/conf.d\/aliases/d' ~/.zshrc
```

## Updating

```bash
cd ~/conf.d && git pull
```

No other steps needed — symlinks follow the repo automatically. After a tmux config change, reload with `prefix` `r`.
