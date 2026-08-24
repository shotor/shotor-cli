#!/usr/bin/env bash
#
# Fetch pinned tooling into .vendor/. bats-core (pure shell), shellcheck and
# shfmt all ship as ready-to-run releases, so bootstrapping only downloads,
# verifies and unpacks them.
#
# Usage: scripts/bootstrap.sh [bats|shellcheck|shfmt|all]
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$script_dir/lib.sh"

root="$(repo_root)"
vendor_dir="$root/.vendor"

bats_core_version="1.11.1"
bats_support_version="0.3.0"
bats_assert_version="2.1.0"
shellcheck_version="0.10.0"
shfmt_version="3.10.0"

bats_core_sha256="5c57ed9616b78f7fd8c553b9bae3c7c9870119edd727ec17dbd1185c599f79d9"
bats_support_sha256="7815237aafeb42ddcc1b8c698fc5808026d33317d8701d5ec2396e9634e2918f"
bats_assert_sha256="98ca3b685f8b8993e48ec057565e6e2abcc541034ed5b0e81f191505682037fd"
shellcheck_sha256="6c881ab0698e4e6ea235245f22832860544f17ba386442fe7e9d629f8cbedf87"
shfmt_sha256="1f57a384d59542f8fac5f503da1f3ea44242f46dff969569e80b524d64b71dbc"

verify_checksum() {
  local file="$1"
  local expected="$2"
  local actual

  actual="$(sha256sum "$file" | cut -d' ' -f1)"

  if [[ "$actual" != "$expected" ]]; then
    echo "bootstrap: checksum mismatch for $file" >&2
    echo "bootstrap:   expected $expected" >&2
    echo "bootstrap:   actual   $actual" >&2
    return 1
  fi
}

fetch_tarball() {
  local url="$1"
  local destination="$2"
  local strip="$3"
  local compression="$4"
  local sha256="$5"
  local archive

  if [[ -d "$destination" ]]; then
    return 0
  fi

  archive="$(mktemp)"
  download "$url" "$archive"
  verify_checksum "$archive" "$sha256" || {
    rm -f "$archive"
    return 1
  }

  mkdir -p "$destination"
  tar "-x${compression}f" "$archive" -C "$destination" --strip-components="$strip"
  rm -f "$archive"
}

fetch_binary() {
  local url="$1"
  local destination="$2"
  local sha256="$3"

  if [[ -x "$destination" ]]; then
    return 0
  fi

  mkdir -p "$(dirname -- "$destination")"
  download "$url" "$destination"
  verify_checksum "$destination" "$sha256" || {
    rm -f "$destination"
    return 1
  }
  chmod 755 "$destination"
}

require_linux_x86_64() {
  local tool="$1"
  local os arch

  os="$(uname -s)"
  arch="$(uname -m)"

  if [[ "$os" != "Linux" || "$arch" != "x86_64" ]]; then
    echo "bootstrap: $tool vendoring supports Linux x86_64 only (found $os $arch)" >&2
    echo "bootstrap: install $tool manually and ensure it is on PATH" >&2
    return 1
  fi
}

bootstrap_bats() {
  fetch_tarball \
    "https://github.com/bats-core/bats-core/archive/refs/tags/v${bats_core_version}.tar.gz" \
    "$vendor_dir/bats-core" 1 z "$bats_core_sha256"

  fetch_tarball \
    "https://github.com/bats-core/bats-support/archive/refs/tags/v${bats_support_version}.tar.gz" \
    "$vendor_dir/bats-support" 1 z "$bats_support_sha256"

  fetch_tarball \
    "https://github.com/bats-core/bats-assert/archive/refs/tags/v${bats_assert_version}.tar.gz" \
    "$vendor_dir/bats-assert" 1 z "$bats_assert_sha256"
}

bootstrap_shellcheck() {
  require_linux_x86_64 shellcheck

  fetch_tarball \
    "https://github.com/koalaman/shellcheck/releases/download/v${shellcheck_version}/shellcheck-v${shellcheck_version}.linux.x86_64.tar.xz" \
    "$vendor_dir/shellcheck" 1 J "$shellcheck_sha256"
}

bootstrap_shfmt() {
  require_linux_x86_64 shfmt

  fetch_binary \
    "https://github.com/mvdan/sh/releases/download/v${shfmt_version}/shfmt_v${shfmt_version}_linux_amd64" \
    "$vendor_dir/shfmt/shfmt" "$shfmt_sha256"
}

target="${1:-all}"

case "$target" in
  bats) bootstrap_bats ;;
  shellcheck) bootstrap_shellcheck ;;
  shfmt) bootstrap_shfmt ;;
  all)
    bootstrap_bats
    bootstrap_shellcheck
    bootstrap_shfmt
    ;;
  *)
    echo "Usage: $0 [bats|shellcheck|shfmt|all]" >&2
    exit 2
    ;;
esac
