# shellcheck shell=bash
#
# Shared test setup: locate the repo, load vendored bats helpers, and expose
# paths used across unit (src/lib/*.bats) and end-to-end (e2e/*.bats) tests.
#
# BATS_TEST_DIRNAME points at the directory of the running .bats file, so the
# repo root is derived by walking up until the marker files are found.

_load_repo_paths() {
  local dir="$BATS_TEST_DIRNAME"

  while [[ "$dir" != "/" && ! -f "$dir/Makefile" ]]; do
    dir="$(dirname -- "$dir")"
  done

  REPO_DIR="$dir"
  SRC_DIR="$REPO_DIR/src"
  LIB_DIR="$SRC_DIR/lib"
  FIXTURES_DIR="$REPO_DIR/e2e/fixtures"
  export REPO_DIR SRC_DIR LIB_DIR FIXTURES_DIR
}

_load_bats_helpers() {
  local vendor="$REPO_DIR/.vendor"
  load "$vendor/bats-support/load.bash"
  load "$vendor/bats-assert/load.bash"
}

load_lib() {
  _load_repo_paths
  # shellcheck source=src/lib/scripts-dir.sh
  # shellcheck disable=SC1091
  source "$LIB_DIR/scripts-dir.sh"
  # shellcheck source=src/lib/discovery.sh
  # shellcheck disable=SC1091
  source "$LIB_DIR/discovery.sh"
  # shellcheck source=src/lib/dispatch.sh
  # shellcheck disable=SC1091
  source "$LIB_DIR/dispatch.sh"
}

load_test_helpers() {
  _load_repo_paths
  _load_bats_helpers
}
