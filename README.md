# autoformat

A code autoformatter for multiple programming languages.

## Features:
* Try to use formatting tools from virtualenv / node_modules, if available - 
  ensure consist results when using different formatter versions (black, isort, prettier, ...) 
* Print pretty diff after formatting
* Cache formatting results - don't rerun formatter on files not changed

## Installation
```
pip install git@github.com:wolkenarchitekt/autoformat.git
```

## Usage
```
autoformat $PATH
```
