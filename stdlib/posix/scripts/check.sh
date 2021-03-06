#!/bin/sh
set -e

missingTools=''
for tool in "$@"; do
  if ! command -v "$tool"; then
    missingTools="$missingTools $tool"
  fi
done
if [ -n "$missingTools" ]; then
  echo >&2 "[WARN] posix: missing tools:$missingTools"
  exit 1
fi
