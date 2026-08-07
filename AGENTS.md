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

## Documentation

- Use `sh` fenced code blocks for CLI explanations, commands, and output examples; never use `text` fences for them.
- Every public executable under `src/commands` must define `@description` and `@usage` metadata; add `@option` lines when applicable.
- Run `./update-readme-scripts.sh` after adding commands or changing their script metadata.

## Backup artifacts

- Store temporary backups and patch artifacts in `.backup/`.
- Do not leave `.orig`, `.rej`, or similar backup files beside source files.

## Avoid

- Do not add dependencies without asking first.
- Do not modify anything in `.devcontainer`; reading it for project context is allowed.
- Do not commit, push, or otherwise publish changes.
- Do not modify unrelated files.
- Do not create additional documentation unless requested.
