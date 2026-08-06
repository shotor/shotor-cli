# shotor-cli

Command-line tools and wrappers I often use.

## Usage

### Command line

> TODO

### Dev container

#### Dependencies

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

## License

[GNU General Public License v2.0](LICENSE.md).
