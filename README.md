# shotor-cli

Bundled scripts I often use. Drop in any standalone script and it just works™.

## Install

Choose a dispatcher name and install it into a directory in `PATH`:

```sh
./install.sh --name love --install-dir "/home/lovelace/.local/bin"
# "love" will now be available as a global executable
```

If `--name` is omitted, the installer uses `str` for the `shotor` user and prompts everyone else. The command directory is installed as `<name>-commands`.

For convenience, add `--link` to symlink instead of copying:

```sh
./install.sh --link --name love --install-dir "/home/lovelace/.local/bin"
```

## Usage

The installed dispatcher discovers executable files under its matching `<name>-commands` directory. For example, `str` uses `str-commands`. Directories become command namespaces, and the remaining arguments are forwarded unchanged to the matched executable.

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

To add a command, place an executable script anywhere under `src/commands`:

```sh
chmod +x src/commands/example
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

Toggle a persistent command in a tmux popup.

```sh
str tmux float [--name <name>] [--kill] [--] [command [argument ...]]

Options:
  --name <name>  Name the persistent float; defaults to default.
  --kill         Kill the named float instead of showing it.
  -h, --help     Show help.
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

### `str vm list`

List all virtual machines and their status.

```sh
str vm list

Options:
  -h, --help  Show help.
```

### `str vm stop`

Stop a VM's user service and then stop the virtual machine.

```sh
str vm stop [--force] <vm-name>

Options:
  --force     Power off the VM immediately.
  -h, --help  Show help.
```

### `str xpra init`

Configure Xpra desktop shortcuts and a user service for a VM.

```sh
str xpra init --name <name> [--user <user>]

Options:
  --name <name>  Virtual machine name.
  --user <user>  Remote VM user; defaults to user.
  -h, --help     Show help.
```

### `str xpra is-running`

Check whether a local Xpra client is connected to a VM.

```sh
str xpra is-running <vm-name>

Options:
  -h, --help  Show help.
```

### `str xpra run`

Start an application in a VM's existing Xpra session.

```sh
str xpra run <vm-name> <vm-ip> <command>

Options:
  -h, --help  Show help.
```

### `str xpra start`

Start a VM and attach to or create its Xpra session.

```sh
str xpra start <vm-name>

Options:
  -h, --help  Show help.
```

### `str xpra start-and-notify`

Start an Xpra VM session and notify systemd when ready.

```sh
str xpra start-and-notify [--timeout <seconds>] <vm-name>

Options:
  --timeout <seconds>  Readiness timeout; defaults to 60 seconds.
  -h, --help           Show help.
```

<!-- END GENERATED SCRIPTS -->

## Development

### Standalone

Make changes directly in the `src` directory from your host machine. No additional development environment is required.

Run the tool from source while developing:

```sh
./src/dispatcher
./src/dispatcher kitty toggle
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
./src/dispatcher
./src/dispatcher kitty toggle
```

### Documentation

The scripts reference is generated from command metadata. Regenerate it after adding or changing commands:

```sh
./generate-scripts.sh
```

## License

[MIT](LICENSE.md)
