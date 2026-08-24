#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$script_dir/lib.sh"

root="$(repo_root)"
shellcheck_bin="$root/.vendor/shellcheck/shellcheck"

if [[ ! -x "$shellcheck_bin" ]]; then
  "$script_dir/bootstrap.sh" shellcheck
fi

cd "$root"
mapfile -t targets < <(shell_sources)

exec "$shellcheck_bin" -x "$@" -- "${targets[@]}"
