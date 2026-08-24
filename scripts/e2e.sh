#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$script_dir/lib.sh"

root="$(repo_root)"
bats="$root/.vendor/bats-core/bin/bats"

if [[ ! -x "$bats" ]]; then
  "$script_dir/bootstrap.sh" bats
fi

exec "$bats" --recursive "$@" "$root/e2e"
