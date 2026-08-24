# shotor-cli

A tiny dispatcher for your personal scripts. Drop any standalone executable into your scripts directory and run it as a subcommand.

## How it works

```sh
love greet formal --loud Ada   # runs scripts/greet/formal --loud Ada
love greet                     # lists commands under scripts/greet
love                           # lists top-level commands
```

`shotor-cli` looks up a scripts directory (in order):

1. `$SHOTOR_SCRIPTS_DIR` if set
2. `${XDG_DATA_HOME:-$HOME/.local/share}/shotor-cli/scripts`
3. a `scripts` directory next to the executable

Then it walks your arguments to find the deepest matching executable and runs it, forwarding the rest of the arguments.

Nested directories become nested subcommands. Because commands live under a single named prefix, they never collide with other tools on your `PATH`.

Any path segment starting with `_` is private and hidden.

Shell completions are installed automatically for Oh My Zsh, Zsh and Bash.

## Install

Grab the prebuilt standalone script from the [latest release](https://github.com/shotor/shotor-cli/releases/latest), drop it somewhere on your `PATH` under any name you like, and make it executable:

```sh
curl -fsSL -o "$HOME/.local/bin/love" https://github.com/shotor/shotor-cli/releases/latest/download/shotor-cli
chmod +x "$HOME/.local/bin/love"
```

Then install shell completions:

```sh
love --install-completions
```

### From source

Clone the repo and run the installer with the name you want:

```sh
git clone https://github.com/shotor/shotor-cli
cd shotor-cli
./install.sh love --install-dir "$HOME/.local/bin"
```

This bundles a standalone executable into `${XDG_DATA_HOME:-$HOME/.local/share}/shotor-cli/` and symlinks the chosen name onto your `PATH`. It also installs shell completions.

Options:

```sh
<name>                Name of the PATH command (required)
--install-dir <path>  Directory on PATH for the symlink (default: ~/.local/bin)
--skip-completions    Do not install shell completions
```

Either way, add your scripts to `${XDG_DATA_HOME:-$HOME/.local/share}/shotor-cli/scripts`.

## Writing scripts

Each script is a normal executable. Nest directories for subcommands:

```sh
scripts/
├── backup            # love backup
└── qemu/
    ├── list          # love qemu list
    ├── create        # love qemu create debian-13
    └── snapshot/     # nest as deep as you like
        └── restore   # love qemu snapshot restore debian-13
```

Anything after the matched command is forwarded to your script unchanged, so read arguments as usual (`$1`, `$@`, flags, and so on).

See `examples/scripts` for working samples.

### Metadata for completions

Add special comments near the top of a script to drive shell completions and help text. They are optional, but recommended:

```sh
#!/usr/bin/env bash
# @description Create a new QEMU virtual machine.
# @usage love qemu create <name>
# @option --disk <size>  Disk size, e.g. 20G
# @option --ram <mb>     Memory in megabytes
set -euo pipefail

# ...
```

- `@description` — one-line summary shown when completing command names.
- `@usage` — the invocation form.
- `@option` — one per flag; text before two-or-more spaces is the flag(s) (comma-separated is fine, e.g. `-l, --loud`), the rest is its description. Flags are offered when completing that command.

Completions are dynamic: they scan the scripts directory and read this metadata at completion time. Adding a new script (or editing its metadata) just works — no regeneration needed. Re-run the installer only to install under a different name.

## Development

```sh
make build         # bundle a standalone executable into build/shotor-cli
make test          # unit tests (src/**/*.bats)
make test-watch    # unit tests in watch mode
make e2e           # end-to-end tests (e2e/)
make lint          # shellcheck
make format        # shfmt with automatic fixing
make format-check  # shfmt without automatic fixing
make check         # lint + test + e2e
make bootstrap     # fetch bats, shellcheck and shfmt into .vendor/
make clean         # remove .vendor/ and build/
```

## License

[MIT](LICENSE.md)
