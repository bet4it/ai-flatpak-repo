#!/bin/sh
set -eu

host_shell="${CCGUI_HOST_SHELL:-/bin/sh}"
exec flatpak-spawn --host "$host_shell" "$@"
