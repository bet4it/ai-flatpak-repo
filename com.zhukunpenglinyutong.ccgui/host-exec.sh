#!/bin/sh
set -eu

command_name=$(basename "$0")
exec flatpak-spawn --host "$command_name" "$@"
