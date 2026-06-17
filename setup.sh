#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing configs"

# Determine source: local repo or download from GitHub
SCRIPT_DIR="$(cd "$(dirname "${0:-.}")" && pwd 2>/dev/null || true)"
if [ -f "$SCRIPT_DIR/tmux.conf" ]; then
    src_prefix() { echo "$SCRIPT_DIR/$1"; }
else
    BASE_URL="https://raw.githubusercontent.com/abienkowski/conf.d/master"
    TMP_FILES=()
    cleanup() { rm -f "${TMP_FILES[@]}"; }
    trap cleanup EXIT
    src_prefix() {
        local tmp; tmp="$(mktemp)"
        TMP_FILES+=("$tmp")
        curl -fsSL "$BASE_URL/$1" -o "$tmp"
        echo "$tmp"
    }
fi

install_file() {
    local src_name="$1" dst_name="$2"
    local src dst="$HOME/$dst_name"
    src="$(src_prefix "$src_name")"

    if [ -f "$dst" ] && cmp -s "$src" "$dst"; then
        echo "  [ok] $dst_name"; return
    fi

    if [ -f "$dst" ]; then
        local stamp; stamp="$(date +%F)"
        local backup="$dst-$stamp"
        if [ ! -e "$backup" ]; then
            cp "$dst" "$backup"
            echo "  [backup] $dst_name -> $dst_name-$stamp"
        else
            echo "  [skip] backup $dst_name-$stamp exists"
        fi
    fi

    cp "$src" "$dst"
    echo "  [install] $dst_name"
}

install_file tmux.conf .tmux.conf
install_file vimrc .vimrc
install_file aliases .aliases

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
