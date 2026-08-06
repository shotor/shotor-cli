#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source_dir="$script_dir/src"
install_dir=""
install_mode="copy"
managed_names=("str" "str-commands")

usage() {
  echo "Usage: $0 [--link] [--install-dir <path>]"
  echo
  echo "Options:"
  echo "  --install-dir <path>  Install into this directory."
  echo "  --link                Symlink str and str-commands instead of copying them."
  echo "  -h, --help            Show this help."
}

resolve_install_dir() {
  local current_user="${USER:-}"

  if [[ -z "$current_user" ]]; then
    current_user=$(id -un)
  fi

  if [[ -z "$install_dir" && "$current_user" == "shotor" ]]; then
    install_dir="$HOME/.shotor/bin"
  elif [[ -z "$install_dir" ]]; then
    printf 'Install directory: ' >&2

    if ! IFS= read -r install_dir || [[ -z "$install_dir" ]]; then
      echo "install: an install directory is required" >&2
      exit 1
    fi
  fi

  if [[ "$install_dir" == "~" || "$install_dir" == "~/"* ]]; then
    install_dir="$HOME${install_dir#\~}"
  fi
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

while [[ $# -gt 0 ]]; do
  case "$1" in
    --install-dir)
      if [[ $# -lt 2 || -z "$2" ]]; then
        usage >&2
        exit 1
      fi
      install_dir="$2"
      shift 2
      ;;
    --link)
      install_mode="link"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 1
      ;;
  esac
done

validate_source
resolve_install_dir
mkdir -p "$install_dir"
remove_managed_targets

if [[ "$install_mode" == "link" ]]; then
  link_source
else
  copy_source
fi
