#!/bin/sh
set -e

test -x "$(command -v java 2>/dev/null)" >/dev/null 2>&1
javac -version 2>&1 | grep -qF 'javac 1.8.'
