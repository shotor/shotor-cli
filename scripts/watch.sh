#!/usr/bin/env bash
#
# Re-run a make target whenever a tracked shell/bats source changes.
#
# Usage: scripts/watch.sh <make-target>
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
# shellcheck disable=SC1091
source "$script_dir/lib.sh"

root="$(repo_root)"
target="${1:?usage: watch.sh <make-target>}"

if ! command -v inotifywait >/dev/null 2>&1; then
  echo "watch: inotifywait not found; install inotify-tools" >&2
  exit 1
fi

cd "$root"

run() {
  clear
  echo "== make $target =="
  make "$target" || true
}

run

while inotifywait -qq -r -e modify,create,delete,move \
  --include '.*\.(sh|bats|bash)$' \
  src scripts e2e examples install.sh Makefile; do
  run
done
