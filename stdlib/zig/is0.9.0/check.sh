#!/bin/sh
set -e

test -x "$(command -v zig 2>/dev/null)" >/dev/null 2>&1
test "$(zig version)" = '0.9.0'
