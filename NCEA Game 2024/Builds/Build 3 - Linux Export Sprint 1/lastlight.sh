#!/bin/sh
echo -ne '\033c\033]0;NCEA Game 2024\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/lastlight.x86_64" "$@"
