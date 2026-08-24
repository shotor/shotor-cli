# shellcheck shell=bash
#
# Resolve the directory that holds Shotor's scripts.
#
# Resolution order:
#   1. $SHOTOR_SCRIPTS_DIR         explicit override (testing / custom setups)
#   2. $XDG_DATA_HOME/shotor-cli/scripts  (defaults to ~/.local/share/...)
#   3. dev fallback: <dir-of-real-executable>/scripts
#
# The dev fallback lets the tool run straight from a checkout where the
# executable and a "scripts" directory live side by side.

# Resolve a path through symlinks without relying on readlink -f (portable).
shotor_resolve_path() {
  local path="$1"
  local dir

  while [[ -L "$path" ]]; do
    dir="$(cd -- "$(dirname -- "$path")" && pwd)"
    path="$(readlink -- "$path")"
    [[ "$path" != /* ]] && path="$dir/$path"
  done

  dir="$(cd -- "$(dirname -- "$path")" && pwd)"
  printf '%s/%s\n' "$dir" "$(basename -- "$path")"
}

shotor_scripts_dir() {
  local executable_source="$1"
  local data_home="${XDG_DATA_HOME:-$HOME/.local/share}"

  if [[ -n "${SHOTOR_SCRIPTS_DIR:-}" ]]; then
    printf '%s\n' "$SHOTOR_SCRIPTS_DIR"
    return 0
  fi

  local xdg_scripts_dir="$data_home/shotor-cli/scripts"

  if [[ -d "$xdg_scripts_dir" ]]; then
    printf '%s\n' "$xdg_scripts_dir"
    return 0
  fi

  local real_executable
  real_executable="$(shotor_resolve_path "$executable_source")"
  printf '%s/scripts\n' "$(dirname -- "$real_executable")"
}
