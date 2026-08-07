#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source_dir="$script_dir/src"
completion_installer="$script_dir/install-completions.sh"
install_dir=""
install_mode="copy"
skip_completions=false
install_name=""

usage() {
  echo "Usage: $0 [--link] [--skip-completions] [--name <name>] [--install-dir <path>]"
  echo
  echo "Options:"
  echo "  --install-dir <path>  Install into this directory."
  echo "  --name <name>         Name the dispatcher and <name>-commands directory."
  echo "  --link                Symlink instead of copying."
  echo "  --skip-completions    Do not install shell completions."
  echo "  -h, --help            Show this help."
}

current_user() {
  if [[ -n "${USER:-}" ]]; then
    printf '%s\n' "$USER"
  else
    id -un
  fi
}

resolve_install_name() {
  local user_name
  user_name=$(current_user)

  if [[ -z "$install_name" && "$user_name" == "shotor" ]]; then
    install_name="str"
  elif [[ -z "$install_name" ]]; then
    printf 'Dispatcher name: ' >&2

    if ! IFS= read -r install_name || [[ -z "$install_name" ]]; then
      echo "install: a dispatcher name is required" >&2
      exit 1
    fi
  fi

  if [[ ! "$install_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "install: invalid dispatcher name: $install_name" >&2
    exit 1
  fi
}

validate_source() {
  if [[ ! -f "$source_dir/dispatcher" || ! -d "$source_dir/commands" ]]; then
    echo "install: expected src/dispatcher and src/commands" >&2
    exit 1
  fi

  if [[ "$skip_completions" == false && ! -x "$completion_installer" ]]; then
    echo "install: expected install-completions.sh" >&2
    exit 1
  fi
}

resolve_install_dir() {
  local user_name
  user_name=$(current_user)

  if [[ -z "$install_dir" && "$user_name" == "shotor" ]]; then
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


remove_managed_targets() {
  local target_path
  local -a target_paths=(
    "$install_dir/$install_name"
    "$install_dir/$install_name-commands"
  )

  for target_path in "${target_paths[@]}"; do
    rm -rf -- "$target_path"
  done
}

copy_source() {
  cp -a "$source_dir/dispatcher" "$install_dir/$install_name"
  cp -a "$source_dir/commands" "$install_dir/$install_name-commands"
}


link_source() {
  ln -s "$source_dir/dispatcher" "$install_dir/$install_name"
  ln -s "$source_dir/commands" "$install_dir/$install_name-commands"
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
    --name)
      if [[ $# -lt 2 || -z "$2" ]]; then
        usage >&2
        exit 1
      fi
      install_name="$2"
      shift 2
      ;;
    --skip-completions)
      skip_completions=true
      shift
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
resolve_install_name
resolve_install_dir
mkdir -p "$install_dir"
remove_managed_targets

if [[ "$install_mode" == "link" ]]; then
  link_source
else
  copy_source
fi

if [[ "$skip_completions" == false ]]; then
  "$completion_installer" "$install_name"
fi
