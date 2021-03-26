#!/bin/sh
set -e

test -x "$(command -v java 2>/dev/null)" >/dev/null 2>&1
java -version 2>&1 | grep -qF '"1.8.'
