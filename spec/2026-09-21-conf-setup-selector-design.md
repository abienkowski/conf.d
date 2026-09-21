# Design: env-var-selected setup.sh

Date: 2026-09-21
Status: approved (2026-09-21)

## Problem

Provisioning a fresh host (dev/test/ops) runs `curl … | sh` to install the
conf.d configs. On hosts like `codeagent`, `~/.tmux.conf` ended up as a stale
standalone copy with no TPM, and the script installs everything always. There
is no way to tell the script which configs to set up.

Symlink-to-repo was explicitly rejected as the install mechanism.

## Goal

A single self-contained `setup.sh` that works unchanged via
`curl -fsSL <raw-url>/master/setup.sh | sh`, with the set of installed units
selected by the `CONF_SETUP` env var. Sensible default = all three units.

## Selection

`CONF_SETUP`:

- Unset, empty, or `all` → `tmux, vimrc, aliases`.
- Comma- or space-separated list drawn from `tmux`, `vimrc`, `aliases`.
- Unknown unit name → print error + valid units, exit 1 (typo safety).

Shell gotcha: with `curl | sh` the env var must prefix `sh`:

```sh
curl -fsSL URL | CONF_SETUP=tmux sh
```

(`CONF_SETUP=… curl URL | sh` only sets it for `curl`.)

## Units (refactor of existing setup.sh)

Order fixed: `tmux, vimrc, aliases`.

| Unit    | Installs                                             |
|---------|------------------------------------------------------|
| `tmux`  | `tmux.conf` → `~/.tmux.conf`, installs/updates TPM   |
| `vimrc` | `vimrc` → `~/.vimrc`                                 |
| `aliases` | `aliases` → `~/.aliases`, ensures `source ~/.aliases` in shell rc |

Unchanged behavior: date-stamped backup of existing dest files, skip when
identical, local-repo-vs-GitHub-download source detection, `set -euo pipefail`
idempotency, rc-file detection for zsh/bash/fish.

Script prints which units were selected and which ran/skipped.

## Docs

README Quick Start and Updating sections gain the `CONF_SETUP` forms.

## Verification

- `sh -n setup.sh`.
- Run against a sandbox `HOME` (empty and pre-existing) for: default,
  `CONF_SETUP=tmux`, `CONF_SETUP=tmux,aliases`, invalid unit name.

## Deployment

Merge the PR, then on codeagent:

```sh
curl -fsSL https://raw.githubusercontent.com/abienkowski/conf.d/master/setup.sh | CONF_SETUP=tmux sh
```

backing up the stale `~/.tmux.conf`, then `prefix I` inside tmux to install
plugins.