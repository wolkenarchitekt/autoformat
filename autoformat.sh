#!/bin/bash
VERSION=1.0.2
VERBOSE=0
POSITIONAL=()
while [[ $# -gt 0 ]]; do
  case $1 in
    -v|--verbose)
      VERBOSE=1
      shift
      ;;
    --version)
      echo "autoformat.sh version ${VERSION}"
      exit 0
      ;;
    --install)
      sudo apt-get install -y git shfmt
      go install github.com/google/yamlfmt/cmd/yamlfmt@latest
      volta install prettier
      cargo install taplo-cli
      uv tool install ruff --force
      uv tool install autoflake --force
      uv tool install isort --force
      sudo ln -sf $(realpath $0) /usr/local/bin/autoformat
      exit 0
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done
set -- "${POSITIONAL[@]}"

log() {
  if [[ $VERBOSE -eq 1 ]]; then
    echo "$@"
  fi
}

find "$1" -type f | while read -r file; do
  git_root=$(git -C "$(dirname ${file})" rev-parse --show-toplevel 2>/dev/null)

  backup=$(mktemp)
  cp --preserve=mode "${file}" "$backup"

  case "${file##*.}" in
  cpp)
    log "clang-format -i \"${file}\""
    clang-format -i "${file}"
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
  toml)
    log "taplo fmt \"${file}\""
    taplo fmt "${file}"
    ;;
  xml)
    xml_backup=$(mktemp)
    log "xmllint --format \"${file}\" >>\"${xml_backup}\""
    xmllint --format "${file}" >>"${xml_backup}"
    cp "${xml_backup}" "${file}"
    ;;
  yml)
    log "yamlfmt \"${file}\""
    yamlfmt "${file}"
    ;;
  *) ;;
  esac

  git --no-pager diff --color $backup "${file}" || true
done
