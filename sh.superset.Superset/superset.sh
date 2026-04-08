#!/bin/sh
set -eu

APPDIR="/app/share/sh.superset.Superset"

export PATH="/app/bin/host-tools:/app/bin:${PATH:-/usr/bin}"
export SUPERSET_HOST_SHELL="${SHELL:-/bin/sh}"
export SUPERSET_HOME_DIR="${SUPERSET_HOME_DIR:-${XDG_DATA_HOME:-${HOME}/.var/app/${FLATPAK_ID}/data}/.superset}"
export SHELL="/app/bin/host-tools/host-shell"
export TMPDIR="${XDG_RUNTIME_DIR:-/tmp}/app/${FLATPAK_ID}"

mkdir -p "$SUPERSET_HOME_DIR" "$TMPDIR"

for candidate in \
  "$APPDIR/Superset" \
  "$APPDIR/superset" \
  "$APPDIR/com.superset.desktop" \
  "$APPDIR/com-superset-desktop"
do
  if [ -x "$candidate" ]; then
    exec zypak-wrapper.sh "$candidate" "$@"
  fi
done

fallback_candidate="$(find "$APPDIR" -maxdepth 1 -type f -perm -111 \
  ! -name chrome-sandbox \
  ! -name chrome_crashpad_handler \
  | head -n 1 || true)"

if [ -n "$fallback_candidate" ]; then
  exec zypak-wrapper.sh "$fallback_candidate" "$@"
fi

printf 'Unable to locate the Superset executable in %s\n' "$APPDIR" >&2
exit 1
