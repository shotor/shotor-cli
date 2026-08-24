#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -ne 1 || ! "$1" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  echo "Usage: $0 <dispatcher-name>" >&2
  exit 2
fi

# shellcheck disable=SC1091
source "$script_dir/lib/completions.sh"

shotor_install_completions "$1"
