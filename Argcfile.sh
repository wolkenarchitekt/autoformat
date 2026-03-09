#!/bin/bash
# @meta version 1.0.0

# @cmd
install() {
  install-argc

  sudo install -m 755 "autoformat.sh" /usr/local/bin/autoformat

  argc --argc-completions bash autoformat |
    sudo tee /etc/bash_completion.d/autoformat 1>/dev/null
}

# @cmd
install-formatters() {
  sudo apt-get install -y git shfmt
  go install github.com/google/yamlfmt/cmd/yamlfmt@latest
  volta install prettier
  cargo install taplo-cli
  uv tool install ruff --force
  uv tool install autoflake --force
  uv tool install isort --force
  uv tool install nginxfmt --force
}

install-argc() {
  if ! command -v argc >/dev/null 2>&1; then
    curl -fsSL https://raw.githubusercontent.com/sigoden/argc/main/install.sh | sh -s -- --to /usr/local/bin
  fi
}

install-argc

eval "$(argc --argc-eval $0 $@)"
