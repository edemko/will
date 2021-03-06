#!/bin/bash
set -e

if [[ "$#" -ne 1 ]]; then
  echo >&2 "usage: $0 <command>"
  exit 1
fi
if [[ "$1" = "--help" ]]; then
  echo >&2 "usage: $0 <command>"
  echo >&2 "  create a package in this directory that just checks for the existence of the named command"
fi

mkdir -p "$1"
{
  echo '#!/bin/sh'
  echo 'set -e'
  echo ''
  echo 'test -x "$(command -v '"$1"' 2>/dev/null)" >/dev/null 2>&1'
} >"$1"/check.sh
