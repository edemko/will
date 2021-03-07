#!/bin/sh
set -e

# determine install directory
bindir=$XDG_BIN_DIR # in anticipation that something like this will be added alongside/into the XDG Base Directory Specification
if [ -z "$bindir" ]; then bindir="$WILL_BINDIR"; fi
if [ -z "$bindir" ]; then bindir="$HOME/bin"; fi

# check usefulness of install directory
if ! test -d "$bindir"; then
  echo >&2 "not a directory: $bindir"
  exit 1
fi
perms="$(ls -l -d "$bindir" | cut -c 2-10)"
case "$perms" in
  rwx------) ;;
  rwx*)
    echo >&2 "[WARN] restrict perms of $bindir to disallow group/other users from accessing (and e.g. installing malware)"
  ;;
esac
if echo "$PATH" | grep -F ":$bindir" >/dev/null 2>&1 \
|| echo "$PATH" | grep -F "$bindir:" >/dev/null 2>&1 \
|| test "$PATH" = "$bindir" >/dev/null 2>&1 ; then
  :
else
  echo >&2 "[WARN] '$bindir' is not on the PATH"
fi

# perform installation
wget 'https://raw.githubusercontent.com/Zankoku-Okuno/will/master/bin/will.bash' -O "$bindir/will"
chmod +x "$bindir/will"

# determine configuration directory
confdir=$XDG_CONFIG_HOME
if [ -z "$confdir" ]; then confdir="$HOME/.config"; fi
confdir="$confdir/will"

# setup a default configuration if needed
if [ ! -e "$confdir/sources" ]; then
  mkdir -p "$confdir"
  wget 'https://raw.githubusercontent.com/Zankoku-Okuno/will/master/config/default' -O "$confdir/sources"
fi

# rebuild package library
"$bindir/will" update
