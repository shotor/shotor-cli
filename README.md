# shotor-cli

CLI tools I often use, bundled behind a wrapper. Drop in any standalone script and it just works™.

## Install

Run the install script, make sure the directory is in PATH:

```sh
./install.sh --install-dir "/home/lovelace/.local/bin"
```

For convenience, add `--link` to symlink instead of copying:

```sh
./install.sh --link --install-dir "/home/lovelace/.local/bin"
```

## Usage

`str` discovers executable files under `str-commands`. Directories become command namespaces, and the remaining arguments are forwarded unchanged to the matched executable.

For example:

```sh
str-commands/
├── kitty/
│   └── toggle
└── tmux/
    └── layout/
        └── ultrawide/
            └── restore
```

These files are available as:

```sh
str kitty toggle
str tmux layout ultrawide restore
```

Run `str` or any namespace by itself to list the commands below it:

```sh
str

Available commands:
  fzf
  kitty
  tmux
  vm
```

```sh
str tmux

Available commands:
  float
  layout
```

```sh
str tmux layout

Available commands:
  ultrawide
```

To add a command, place an executable script anywhere under `str-commands`:

```sh
chmod +x str-commands/example
str example
```

Files and directories beginning with `_` are private and are not listed or dispatched.

## Scripts

<!-- BEGIN GENERATED SCRIPTS -->

### `str fzf commands`

Interactively select and run a shell command.

```sh
str fzf commands
```

### `str kitty toggle`

Toggle the Kitty window and manage its KDE integration.

```sh
str kitty toggle [--debug|--install]

Options:
  --debug     Print window detection and toggle decisions to stderr.
  --install   Install the KDE shortcut and window rule.
  -h, --help  Show help.
```

### `str tmux float`

Run a command in a tmux popup sized relative to the center pane.

```sh
str tmux float <command> [argument ...]
```

### `str tmux layout ultrawide restore`

Restore the five-pane ultrawide tmux layout.

```sh
str tmux layout ultrawide restore [--keep-active]

Options:
  --keep-active  Keep the active pane as the logical center.
  -h, --help     Show help.
```

### `str tmux layout ultrawide set`

Create the five-pane ultrawide tmux layout.

```sh
str tmux layout ultrawide set [--kill-others] [-t <pane-id>]

Options:
  --kill-others  Kill all other panes before setting the layout.
  -t <pane-id>   Target pane; defaults to the active pane.
  -h, --help     Show help.
```

### `str vm get-ip`

Print the non-loopback IPv4 address of a virtual machine.

```sh
str vm get-ip <vm-name>
```

<!-- END GENERATED SCRIPTS -->

## Development

### Standalone

Make changes directly in the `src` directory from your host machine. No additional development environment is required.

Run the tool from source while developing:

```sh
./src/str
./src/str kitty toggle
```

### DevContainer

Install dependencies:

- [Docker](https://docs.docker.com/get-docker/)
- [Visual Studio Code](https://code.visualstudio.com/) or [VSCodium](https://vscodium.com/)
- One of the following:
  - The [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
  - [Devsy](https://devsy.sh/) with the [Open Remote - SSH extension](https://open-vsx.org/extension/jeanp413/open-remote-ssh)

Create your local environment file and update it:

```sh
cp .devcontainer/.env.example .devcontainer/.env
```

When using `VSCodium`, run the extension installer inside the container after it starts:

```sh
.devcontainer/install-extensions.sh
```

Run the tool:

```sh
./src/str
./src/str kitty toggle
```

### Documentation

The scripts reference is generated from command metadata. Regenerate it after adding or changing commands:

```sh
./generate-scripts.sh
```

## License

[MIT](LICENSE.md)
