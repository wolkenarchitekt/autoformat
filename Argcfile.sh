#!/bin/bash
# @meta version 1.0.0

# @cmd
install() {
  install-argc

  if [[ "$(realpath "$BASH_SOURCE")" != "/usr/local/bin/autoformat" ]]; then
    sudo install -m 755 "$BASH_SOURCE" /usr/local/bin/autoformat
  fi

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
