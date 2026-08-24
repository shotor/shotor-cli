# shellcheck shell=bash
#
# Shared helpers for the scripts/ tooling: repository paths and downloads.

repo_root() {
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd
}

# Print (NUL-separated) the shell scripts that lint/format operate on, relative
# to the repo root. .bats files are excluded (they are not valid sh). Run from
# the repo root.
shell_sources() {
  {
    printf '%s\n' \
      src/shotor-cli \
      src/install-completions.sh \
      install.sh
    find src/lib scripts -type f -name '*.sh'
    find examples/scripts e2e/fixtures/scripts -type f -perm /111
  } | sort -u
}

# Download a URL to a destination file using curl or wget.
download() {
  local url="$1"
  local destination="$2"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$destination"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$destination" "$url"
  else
    echo "download: need curl or wget to fetch $url" >&2
    return 1
  fi
}
