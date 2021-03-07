#!/bin/sh
set -e

bindir=$XDG_BIN_DIR
if [ -z "$bindir" ]; then bindir="$WILL_BINDIR"; fi
if [ -z "$bindir" ]; then bindir="$HOME/bin"; fi

test -d "$bindir"

perms="$(ls -l -d "$bindir" | cut -c 2-10)"
case "$perms" in
  rwx------) ;;
  rwx*)
    echo >&2 "restrict perms of ~/bin to disallow group/other users from accessing (and e.g. installing malware)"
    exit 1
  ;;
  *------) exit 1 ;;
esac

if echo "$PATH" | grep -F ":$bindir" >/dev/null 2>&1 \
|| echo "$PATH" | grep -F "$bindir:" >/dev/null 2>&1 \
|| test "$PATH" = "$bindir" >/dev/null 2>&1 ; then
  :
else
  echo >&2 "'$bindir' is not on the PATH"
  exit 1
fi
