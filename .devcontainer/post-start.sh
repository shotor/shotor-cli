#!/usr/bin/env bash
set -e

echo "Running post-start.sh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

if [ -f "$ENV_FILE" ]; then
  echo "---------- .env ----------"
  cat "$ENV_FILE"
  echo "--------------------------"

  set -a
  source "$ENV_FILE"
  set +a
else
  echo "==> ERROR: $ENV_FILE not found"
  exit 1
fi

echo "Creating $HOME/.ssh"
mkdir -pv "$HOME/.ssh"

echo "Configuring Git"

git config user.name "$GIT_USER_NAME"
git config user.email "$GIT_USER_EMAIL"

printf '%s\n' "$GIT_SIGNING_KEY" > "$HOME/.ssh/signing.pub"
chmod 644 "$HOME/.ssh/signing.pub"

git config gpg.format ssh
git config user.signingkey "$HOME/.ssh/signing.pub"
git config commit.gpgsign true
git config tag.gpgSign true

echo "Git Config:"
echo "  user.name:       $(git config --local --get user.name)"
echo "  user.email:      $(git config --local --get user.email)"
echo "  user.signingkey: $(git config --local --get user.signingkey)"
