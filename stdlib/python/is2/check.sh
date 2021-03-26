#!/bin/sh
set -e

exec >/dev/null 2>/dev/null

test -x "$(command -v python 2>/dev/null)"
# apparently python 2.7.12 puts the result of -V onto stderr‽
python --version 2>&1 | grep -q '^Python 2\.'
