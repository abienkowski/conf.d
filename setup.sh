#!/usr/bin/env bash
set -eu
( set -o pipefail ) 2>/dev/null && set -o pipefail

echo "==> Installing configs"

# Determine source: local repo or download from GitHub
SCRIPT_DIR="$(cd "$(dirname "${0:-.}")" && pwd 2>/dev/null || true)"
if [ -f "$SCRIPT_DIR/tmux.conf" ]; then
    src_prefix() { echo "$SCRIPT_DIR/$1"; }
else
    BASE_URL="https://raw.githubusercontent.com/abienkowski/conf.d/master"
    TMP_FILES=""
    cleanup() { rm -f $TMP_FILES; }
    trap cleanup EXIT
    src_prefix() {
        local tmp; tmp="$(mktemp)"
        TMP_FILES="$TMP_FILES $tmp"
        curl -fsSL "$BASE_URL/$1" -o "$tmp" || {
            echo "ERROR: Failed to download $BASE_URL/$1" >&2
            exit 1
        }
        if [ ! -s "$tmp" ]; then
            echo "ERROR: Downloaded $BASE_URL/$1 is empty" >&2
            exit 1
        fi
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

    if [ -f "$dst" ] || [ -L "$dst" ]; then
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

# CONF_SETUP: comma- or space-separated subset of tmux,vimrc,aliases.
# Unset, empty, or "all" means all units. Unknown names abort the script.
CONF_SETUP="${CONF_SETUP:-}"
[ -z "$CONF_SETUP" ] && CONF_SETUP="all"
CONF_SETUP="$(printf '%s' "$CONF_SETUP" | tr ', ' ' ')"
# shellcheck disable=SC2086
set -- $CONF_SETUP
CONF_SETUP="$*"
[ -z "$CONF_SETUP" ] && CONF_SETUP="all"

units="tmux vimrc aliases"

for unit in $CONF_SETUP; do
    case " $units all " in
        *" $unit "*) ;;
        *)
            echo "ERROR: unknown CONF_SETUP unit '$unit'" >&2
            echo "Valid units: $units (or 'all')" >&2
            exit 1
            ;;
    esac
done

want() {
    case " $CONF_SETUP " in
        *" $1 "*|*" all "*) return 0 ;;
    esac
    return 1
}

# Shell rc for aliases
SHELL_NAME="$(basename "${SHELL:-zsh}")"
rc="$HOME/.${SHELL_NAME}rc"
[ "$SHELL_NAME" = "fish" ] && rc="$HOME/.config/fish/config.fish"

for unit in $units; do
    want "$unit" || continue
    echo "  [unit] $unit"
    case "$unit" in
        tmux)
            install_file tmux.conf .tmux.conf
            tpm="$HOME/.tmux/plugins/tpm"
            if [ ! -d "$tpm" ]; then
                git clone https://github.com/tmux-plugins/tpm "$tpm"
                echo "  [tpm] installed"
            else
                git -C "$tpm" pull --ff-only --quiet 2>/dev/null || true
                echo "  [ok] tpm"
            fi
            ;;
        vimrc)
            install_file vimrc .vimrc
            ;;
        aliases)
            install_file aliases .aliases
            line="source $HOME/.aliases"
            if ! grep -qxF "$line" "$rc" 2>/dev/null; then
                echo "$line" >> "$rc"
                echo "  [rc] added source to $rc"
            else
                echo "  [ok] rc"
            fi
            ;;
    esac
done

echo ""
echo "All set! Start tmux and press prefix + I to install plugins."
echo "Reload shell: source $rc"
