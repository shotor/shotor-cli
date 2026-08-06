FROM mcr.microsoft.com/devcontainers/javascript-node:24

RUN sudo apt update && \
  sudo apt install -y \
    jq \
    lsd \
    tmux \
    vim && \
    chsh -s /usr/bin/zsh node

RUN curl -fsSL https://starship.rs/install.sh | sh -s -- -y \
  && npm install -g @openai/codex

COPY .zshrc /home/node/.zshrc
COPY starship.toml /home/node/.config/starship.toml
