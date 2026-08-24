#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source_dir="$script_dir/src"
build_script="$script_dir/scripts/build.sh"
completion_installer="$source_dir/install-completions.sh"
data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
home_dir="$data_home/shotor-cli"
install_dir=""
skip_completions=false
install_name=""

usage() {
  echo "Usage: $0 <name> [--skip-completions] [--install-dir <path>]"
  echo
  echo "Installs the shotor dispatcher into $home_dir and links it onto PATH."
  echo
  echo "Arguments:"
  echo "  <name>                Name of the PATH command (required)."
  echo
  echo "Options:"
  echo "  --install-dir <path>  Directory on PATH for the command symlink"
  echo "                        (default: \$XDG_BIN_HOME or ~/.local/bin)."
  echo "  --skip-completions    Do not install shell completions."
  echo "  -h, --help            Show this help."
}

validate_source() {
  if [[ ! -f "$source_dir/shotor-cli" || ! -d "$source_dir/lib" ]]; then
    echo "install: expected src/shotor-cli and src/lib" >&2
    exit 1
  fi

  if [[ ! -x "$build_script" ]]; then
    echo "install: expected scripts/build.sh" >&2
    exit 1
  fi

  if [[ "$skip_completions" == false && ! -x "$completion_installer" ]]; then
    echo "install: expected src/install-completions.sh" >&2
    exit 1
  fi
}

resolve_install_dir() {
  if [[ -z "$install_dir" ]]; then
    install_dir="${XDG_BIN_HOME:-$HOME/.local/bin}"
  fi

  # shellcheck disable=SC2088  # matching a literal tilde before expanding it
  if [[ "$install_dir" == "~" || "$install_dir" == "~/"* ]]; then
    install_dir="$HOME${install_dir#\~}"
  fi
}

install_home() {
  rm -rf -- "${home_dir:?}/lib"
  mkdir -p "$home_dir/scripts"
  "$build_script" "$home_dir/shotor-cli"
}

link_command() {
  local target="$install_dir/$install_name"

  rm -f -- "$target"
  ln -s "$home_dir/shotor-cli" "$target"
  echo "Linked $target -> $home_dir/shotor-cli"
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
    --skip-completions)
      skip_completions=true
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    -*)
      usage >&2
      exit 1
      ;;
    *)
      if [[ -n "$install_name" ]]; then
        usage >&2
        exit 1
      fi
      install_name="$1"
      shift
      ;;
  esac
done

if [[ -z "$install_name" ]]; then
  printf 'Command name: ' >&2
  if ! IFS= read -r install_name || [[ -z "$install_name" ]]; then
    echo "install: a command name is required" >&2
    exit 1
  fi
fi

if [[ ! "$install_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  echo "install: invalid command name: $install_name" >&2
  exit 1
fi

validate_source
resolve_install_dir
mkdir -p "$install_dir"
install_home
link_command

echo "Scripts directory: $home_dir/scripts"
echo "Add scripts there, or set SHOTOR_SCRIPTS_DIR to override."

if [[ "$skip_completions" == false ]]; then
  "$completion_installer" "$install_name"
fi
