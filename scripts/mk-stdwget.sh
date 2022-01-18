#!/bin/bash
set -e

echo >&2 "[WARNING] deprecated in favor of using \`skel mk will wget\`"

if [[ "$1" = "--help" ]]; then
  echo >&2 "usage: $0 <command> <url>"
  echo >&2 "  create a package in this directory that just checks for the existence of the named command"
  echo >&2 "  with an install script that just downloads the url into ~/bin/<package name>"
fi
if [[ "$#" -ne 2 ]]; then
  echo >&2 "usage: $0 <command> <url>"
  exit 1
fi

mkdir -p "$1"
{
  echo '#!/bin/sh'
  echo 'set -e'
  echo ''
  echo 'test -x "$(command -v '"$1"' 2>/dev/null)" >/dev/null 2>&1'
} >"$1"/check.sh
{
  echo '#!/bin/sh'
  echo 'set -e'
  echo ''
  echo "dlUrl='$2'"
  echo 'installPath="$HOME/bin/'"$1"'"'
  echo ''
  echo 'echo "[FILE] $installPath"'
  echo 'wget "$dlUrl" -O "$installPath"'
  echo 'chmod +x "$installPath"'
} >"$1"/install
chmod +x "$1"/install
