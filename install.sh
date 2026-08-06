#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source_dir="$script_dir/src"
install_dir="$HOME/.shotor/bin"

shopt -s dotglob nullglob
source_entries=("$source_dir"/*)

mkdir -p "$install_dir"

if (( ${#source_entries[@]} > 0 )); then
  cp -a "${source_entries[@]}" "$install_dir/"
fi
