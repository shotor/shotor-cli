#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source_dir="$script_dir/src"
install_dir="$HOME/.shotor/bin"
install_mode="copy"
managed_names=("str" "str-commands")

usage() {
  echo "Usage: $0 [--link]"
  echo
  echo "Options:"
  echo "  --link      Symlink str and str-commands instead of copying them."
  echo "  -h, --help  Show this help."
}

validate_source() {
  if [[ ! -f "$source_dir/str" || ! -d "$source_dir/str-commands" ]]; then
    echo "install: expected src/str and src/str-commands" >&2
    exit 1
  fi
}

remove_managed_targets() {
  local managed_name
  local target_path

  for managed_name in "${managed_names[@]}"; do
    target_path="$install_dir/$managed_name"
    rm -rf -- "$target_path"
  done
}

copy_source() {
  cp -a \
    "$source_dir/str" \
    "$source_dir/str-commands" \
    "$install_dir/"
}

link_source() {
  ln -s "$source_dir/str" "$install_dir/str"
  ln -s "$source_dir/str-commands" "$install_dir/str-commands"
}

case "${1:-}" in
  --link)
    [[ $# -eq 1 ]] || { usage >&2; exit 1; }
    install_mode="link"
    ;;
  -h|--help)
    usage
    exit 0
    ;;
  "")
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac

validate_source
mkdir -p "$install_dir"
remove_managed_targets

if [[ "$install_mode" == "link" ]]; then
  link_source
else
  copy_source
fi
