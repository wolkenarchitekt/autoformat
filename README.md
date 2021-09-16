# autoformat

A code autoformatter for multiple programming languages.

## Features:
* Try to use formatting tools from virtualenv / node_modules, if available - 
  ensure consistent results when using different formatter versions (black, isort, prettier, ...) 
* Print pretty diff after formatting
* Cache formatting results - don't rerun formatter on files not changed

## Supported file types / languages

* Python (using [autoflake](https://pypi.org/project/autoflake/), [isort](https://github.com/PyCQA/isort), [black](https://black.readthedocs.io/en/stable/))
* Javascript (using [prettier](https://prettier.io/))
* SQL (using [sqlparse](https://pypi.org/project/sqlparse/))
* JSON (using [jq](https://stedolan.github.io/jq/))

## Installation
```
pip install git+git://github.com/wolkenarchitekt/autoformat.git#egg=autoformat
```

## Usage
```
autoformat $PATH
```

## Integrate into PyCharm

To integrate autoformat into PyCharm, add a new External Tool (Settings, Tools, External Tools).

Tool Settings:
```
Program: $ContentRoot$/.venv/bin/autoformat
Arguments: $FileRelativePath$
Working directory: 
```