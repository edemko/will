#!/bin/sh
set -e

test -x "$(command -v zedo 2>/dev/null)" >/dev/null 2>&1
zedo --version | grep -q '^zedo-shim ' 2>/dev/null
