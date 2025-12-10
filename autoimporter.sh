#!/bin/bash
inputfile="${1}"
tmpfile="$(mktemp)"
cp "${inputfile}" "${tmpfile}"
autoimport "$@"
git --no-pager diff --color "${tmpfile}" "${inputfile}"
