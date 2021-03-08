#!/bin/sh
set -e

exec >/dev/null 2>/dev/null

test -x "$(command -v python 2>/dev/null)"
python --version | grep -q '^Python 3\.'
