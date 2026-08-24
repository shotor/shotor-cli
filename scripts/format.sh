#!/usr/bin/env bash
#
# Format shell sources with shfmt (2-space indent). Pass --check to verify
# formatting without writing changes.
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
# shellcheck disable=SC1091
source "$script_dir/lib.sh"

root="$(repo_root)"
shfmt_bin="$root/.vendor/shfmt/shfmt"

if [[ ! -x "$shfmt_bin" ]]; then
  "$script_dir/bootstrap.sh" shfmt
fi

cd "$root"
mapfile -t targets < <(shell_sources)

# -i 2: two-space indent, -ci: indent switch cases, -bn: binary ops at line start
if [[ "${1:-}" == "--check" ]]; then
  exec "$shfmt_bin" -i 2 -ci -bn -d -- "${targets[@]}"
fi

exec "$shfmt_bin" -i 2 -ci -bn -w -- "${targets[@]}"
