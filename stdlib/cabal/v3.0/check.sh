#!/bin/sh
set -e

test -x "$(command -v cabal-3.0 2>/dev/null)" >/dev/null 2>&1
