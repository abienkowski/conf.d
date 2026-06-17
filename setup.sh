#!/usr/bin/env bash
set -euo pipefail

REPO_URL="git@github.com:abienkowski/conf.d.git"
REPO_DIR="${REPO_DIR:-$HOME/conf.d}"

# If run via curl-pipe (not inside the repo), clone and re-exec
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd 2>/dev/null || true)"
if [ ! -f "$SCRIPT_DIR/tmux.conf" ]; then
    echo "==> Cloning conf.d into $REPO_DIR ..."
    git clone "$REPO_URL" "$REPO_DIR"
    exec "$REPO_DIR/setup.sh"
fi

REPO_DIR="$SCRIPT_DIR"

echo "==> Installing configuration files from $REPO_DIR"

# --- helpers ----------------------------------------------------------------
backup_and_symlink() {
    local src="$1"
    local dst="$2"
    local name="$3"

    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        echo "  [ok] $name symlink already correct"
        return
    fi

    if [ -e "$dst" ] || [ -L "$dst" ]; then
        local stamp
        stamp="$(date +%F)"
        mv "$dst" "$dst-$stamp"
        echo "  [backup] existing $name -> $dst-$stamp"
    fi

    ln -sf "$src" "$dst"
    echo "  [link] $dst -> $src"
}

detect_rc_file() {
    local shell_name
    shell_name="$(basename "${SHELL:-/bin/zsh}")"
    case "$shell_name" in
        zsh)  echo "$HOME/.zshrc" ;;
        bash) echo "$HOME/.bashrc" ;;
        fish) echo "$HOME/.config/fish/config.fish" ;;
        *)    echo "$HOME/.zshrc" ;;
    esac
}

ensure_sourced() {
    local file="$1"
    local rc="$2"
    local line="source $file"

    if [ ! -f "$rc" ]; then
        echo "$line" > "$rc"
        echo "  [create] $rc with source line"
        return
    fi

    if grep -qxF "$line" "$rc" 2>/dev/null; then
        echo "  [ok] aliases already sourced in $rc"
    else
        echo "" >> "$rc"
        echo "$line" >> "$rc"
        echo "  [append] added 'source $file' to $rc"
    fi
}

# --- symlink config files ---------------------------------------------------
echo ""
echo ">>> Setting up tmux.conf ..."
backup_and_symlink "$REPO_DIR/tmux.conf" "$HOME/.tmux.conf" ".tmux.conf"

echo ""
echo ">>> Setting up vimrc ..."
backup_and_symlink "$REPO_DIR/vimrc" "$HOME/.vimrc" ".vimrc"

echo ""
echo ">>> Setting up aliases ..."
backup_and_symlink "$REPO_DIR/aliases" "$HOME/.aliases" ".aliases"

RC_FILE="$(detect_rc_file)"
echo ""
echo ">>> Detected shell: $(basename "${SHELL:-zsh}") -> rc: $RC_FILE"
ensure_sourced "$HOME/.aliases" "$RC_FILE"

# --- install TPM -----------------------------------------------------------
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    echo ""
    echo ">>> Installing Tmux Plugin Manager (TPM) into $TPM_DIR ..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
    echo ""
    echo ">>> TPM already installed at $TPM_DIR"
fi

# --- summary ---------------------------------------------------------------
echo ""
echo "=========================================="
echo "  Setup complete!"
echo "=========================================="
echo ""
echo "  Post-install steps:"
echo ""
echo "  1. Start tmux and press  prefix + I  (capital I)"
echo "     to install TPM plugins (tmux-resurrect, tmux-sensible)."
echo ""
echo "  2. Reload your shell:"
echo "       source $RC_FILE"
echo ""
echo "  3. (Neo)vim will pick up ~/.vimrc automatically on next launch."
echo ""
echo "  4. To update configs later:"
echo "       cd $REPO_DIR && git pull"
echo ""
