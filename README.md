# autoformat

A unified script to format code in multiple programming languages with a single command.

## Supported file types / languages

* Dart (using [dart format](https://dart.dev/tools/dart-format))
* Python (using [autoflake](https://pypi.org/project/autoflake/), [isort](https://github.com/PyCQA/isort), [black](https://black.readthedocs.io/en/stable/))
* Javascript, JSX and HTML (using [prettier](https://prettier.io/))
* SQL (using [sqlparse](https://pypi.org/project/sqlparse/))
* JSON (using [jq](https://stedolan.github.io/jq/))
* YAML (using [yamlfmt](https://github.com/google/yamlfmt))
* Shell (using [shfmt](https://webinstall.dev/shfmt/))
* TOML (using [taplo](https://github.com/tamasfe/taplo))
* Ruby, Vagrantfile (using [rufo](https://github.com/ruby-formatter/rufo))
* Nginx conf (using [nginxfmt](https://github.com/slomkowski/nginx-config-formatter))

## Usage
```
autoformat $PATH
```
