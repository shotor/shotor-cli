#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVCONTAINER_FILE="$SCRIPT_DIR/devcontainer.json"

jq -r '.customizations.vscode.extensions[]' "$DEVCONTAINER_FILE" |
while read -r ext; do
  echo "Installing $ext..."
  codium --install-extension "$ext" --force
done
