#!/bin/sh
set -eu

ORIG_SHELL="${SHELL:-/bin/sh}"

export PATH="/app/bin/host-tools:/app/bin:${PATH:-/usr/bin}"
export CCGUI_HOST_SHELL="$ORIG_SHELL"
export SHELL="/app/bin/host-tools/host-shell"
export TMPDIR="${XDG_RUNTIME_DIR:-/tmp}/app/${FLATPAK_ID}"

mkdir -p "$TMPDIR"

exec /app/bin/ccgui-bin "$@"
