#!/bin/bash
# @meta version 1.1.2
# @meta description Auto-format source files using language-specific formatters
set -euo pipefail

# @cmd Format files or directories
# @flag -v --verbose Enable verbose output
# @flag -n --dry-run Show what would be formatted without making changes
# @arg targets* Files or directories to format (default: current directory)
# @meta default-subcommand
format() {
  local targets=("${argc_targets[@]:-"."}")

  for t in "${targets[@]}"; do
    if [[ -d "$t" ]]; then
      find "$t" -type f | while read -r file; do
        format_file "$file"
      done
    elif [[ -f "$t" ]]; then
      format_file "$t"
    else
      log "Skipping non-existent path: $t"
    fi
  done
}

log() {
  if [[ "${argc_verbose:-0}" -eq 1 ]]; then
    echo "$@"
  fi
}

format_file() {
  local file="$1"
  local backup json_backup xml_backup

  backup=$(mktemp)
  cp --preserve=mode "${file}" "$backup"

  case "${file##*.}" in
  cpp | hpp | h)
    log "clang-format -i \"${file}\""
    clang-format -i "${file}"
    ;;
  conf | template)
    log "nginxfmt \"${file}\""
    nginxfmt "${file}"
    ;;
  dart)
    log "dart format \"${file}\""
    dart format "${file}"
    ;;
  js | jsx | html | css)
    log "prettier --log-level warn --write \"${file}\""
    prettier --log-level warn --write "${file}"
    ;;
  json)
    json_backup=$(mktemp)
    log "jq . \"${file}\" >>\"${json_backup}\""
    jq . "${file}" >>"${json_backup}"
    cp "${json_backup}" "${file}"
    ;;
  py)
    log "ruff format --quiet \"${file}\""
    ruff format --quiet "${file}"
    log "autoflake --in-place --remove-all-unused-imports \"${file}\""
    autoflake --in-place --remove-all-unused-imports "${file}"
    log "isort -q \"${file}\""
    isort -q "${file}"
    ;;
  rb)
    log "rufo \"${file}\""
    rufo "${file}"
    ;;
  sh)
    log "shfmt -i 2 -w \"${file}\""
    shfmt -i 2 -w "${file}"
    ;;
  swift)
    # https://www.swift.org/install/linux/
    # https://github.com/nicklockwood/SwiftFormat
    log "swiftformat \"${file}\""
    swiftformat --swift-version 6 "${file}"
    ;;
  toml)
    log "taplo fmt \"${file}\""
    taplo fmt "${file}"
    ;;
  xml | svg)
    xml_backup=$(mktemp)
    log "xmllint --format \"${file}\" >>\"${xml_backup}\""
    xmllint --format "${file}" >>"${xml_backup}"
    cp "${xml_backup}" "${file}"
    ;;
  yml | yaml)
    log "yamlfmt \"${file}\""
    yamlfmt "${file}"
    ;;
  *)
    return
    ;;
  esac

  git --no-pager diff --color "$backup" "${file}" || true

  if [[ "${argc_dry_run:-0}" -eq 1 ]]; then
    cp --preserve=mode "$backup" "${file}"
  fi
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

# @cmd
install() {
  sudo install -m 755 "$BASH_SOURCE" /usr/local/bin/autoformat

  if [ -d "/etc/bash_completion.d" ] && [ ! -f "/etc/bash_completion.d/autoformat" ]; then
    argc --argc-completions bash autoformat | sudo tee /etc/bash_completion.d/autoformat 1>/dev/null
  fi
}

install_argc() {
  if ! command -v argc >/dev/null 2>&1; then
    curl -fsSL https://raw.githubusercontent.com/sigoden/argc/main/install.sh | sudo sh -s -- --to /usr/local/bin
  fi
  if [ ! -f "/etc/bash_completion.d/argc" ]; then
    argc --argc-completions bash | sudo tee /etc/bash_completion.d/argc >/dev/null
    echo "Bash completion installed to /etc/bash_completion.d/argc. Reload shell to activate."
  fi
}

install_argc

eval "$(argc --argc-eval "$0" "$@")"
