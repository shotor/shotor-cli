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

## License

[GNU General Public License v2.0](LICENSE.md)
