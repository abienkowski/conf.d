#!/usr/bin/env bash
set -euo pipefail

REPO_URL="git@github.com:abienkowski/conf.d.git"
REPO_DIR="${REPO_DIR:-$HOME/conf.d}"

# If piped via stdin ($0=bash), clone the repo and re-exec
SCRIPT_DIR="$(cd "$(dirname "${0:-.}")" && pwd 2>/dev/null || true)"
if [ ! -f "$SCRIPT_DIR/tmux.conf" ]; then
    echo "==> Setting up conf.d ..."
    if [ -d "$REPO_DIR" ]; then git -C "$REPO_DIR" pull
    else git clone "$REPO_URL" "$REPO_DIR"; fi
    exec "$REPO_DIR/setup.sh"
fi
REPO_DIR="$SCRIPT_DIR"

echo "==> Installing configs from $REPO_DIR"

link_config() {
    local name="$1"
    local src="$REPO_DIR/$name"
    local dst="$HOME/$name"
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        echo "  [ok] $name"; return
    fi
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        local stamp; stamp="$(date +%F)"
        mv "$dst" "$dst-$stamp"
        echo "  [backup] $name -> $name-$stamp"
    fi
    ln -sf "$src" "$dst"
    echo "  [link] $name"
}

link_config .tmux.conf
link_config .vimrc
link_config .aliases

# Detect shell rc file and add source for aliases
SHELL_NAME="$(basename "${SHELL:-zsh}")"
rc="$HOME/.${SHELL_NAME}rc"
[ "$SHELL_NAME" = "fish" ] && rc="$HOME/.config/fish/config.fish"

line="source $HOME/.aliases"
if ! grep -qxF "$line" "$rc" 2>/dev/null; then
    echo "$line" >> "$rc"
    echo "  [rc] added source to $rc"
else
    echo "  [ok] rc"
fi

# Install TPM
tpm="$HOME/.tmux/plugins/tpm"
if [ ! -d "$tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$tpm"
    echo "  [tpm] installed"
else
    echo "  [ok] tpm"
fi

echo ""
echo "All set! Start tmux and press prefix + I to install plugins."
echo "Reload shell: source $rc"
