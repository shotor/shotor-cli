# Project instructions

## Code style

- Write Bash scripts using `#!/usr/bin/env bash`.
- Use `set -euo pipefail` in Bash scripts.
- Quote variable expansions unless intentional word splitting is required.
- Prefer clear, descriptive variable names.
- Keep scripts small and focused.

## Project structure

- Put each top-level tool in its own directory.
- Name a tool's main executable after its directory.
- Commands must be executable and accept forwarded arguments unchanged.

## Verification

- Run `bash -n` after changing a Bash script.
- Test successful and unsuccessful command dispatch when changing Shotor.
- Keep error messages concise and write them to standard error.

## Avoid

- Do not add dependencies without asking first.
- Do not read, display, or modify anything in `.devcontainer`.
- Do not commit, push, or otherwise publish changes.
- Do not modify unrelated files.
- Do not create additional documentation unless requested.
