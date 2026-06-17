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

# Remove source line from shell rc
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
