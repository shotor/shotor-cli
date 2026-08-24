#!/usr/bin/env bash
#
# Build a single standalone `shotor-cli` executable by inlining src/lib/*.sh into
# the entrypoint, replacing the dev-only source block delimited by the
# SHOTOR_BUNDLE_LIB markers.
#
# Usage: scripts/build.sh [output-path]   (default: build/shotor-cli)
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
# shellcheck disable=SC1091
source "$script_dir/lib.sh"

root="$(repo_root)"
source_dir="$root/src"
entrypoint="$source_dir/shotor-cli"
destination="${1:-$root/build/shotor-cli}"

if [[ ! -f "$entrypoint" || ! -d "$source_dir/lib" ]]; then
  echo "build: expected src/shotor-cli and src/lib" >&2
  exit 1
fi

mkdir -p "$(dirname -- "$destination")"

lib_bundle="$(mktemp)"
trap 'rm -f "$lib_bundle"' EXIT

# Concatenate the libraries, stripping full-line comments (documentation and
# per-file lint directives) since they add no value in the generated bundle.
# completions.sh is inlined verbatim (minus its lint directive): its heredocs
# contain '#' lines that make up the generated completion scripts.
for lib_file in "$source_dir"/lib/*.sh; do
  if [[ "$(basename -- "$lib_file")" == completions.sh ]]; then
    grep -v '^# shellcheck shell=bash$' "$lib_file" >>"$lib_bundle"
  else
    sed '/^[[:space:]]*#/d' "$lib_file" >>"$lib_bundle"
  fi
done

awk -v lib_bundle="$lib_bundle" '
  /# >>> SHOTOR_BUNDLE_LIB/ {
    skipping = 1
    while ((getline line < lib_bundle) > 0) {
      print line
    }
    close(lib_bundle)
    next
  }
  /# <<< SHOTOR_BUNDLE_LIB/ { skipping = 0; next }
  !skipping { print }
' "$entrypoint" >"$destination"

chmod 755 "$destination"
echo "Built $destination"
