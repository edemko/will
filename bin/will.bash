#!/bin/bash
set -e

# FIXME: arg parsing should detect `--` as end-of-options
# FIXME: global options should be available for use after the command

version=0.1.0

usage="usage $0 [global options] <command> [args]"'

Global Options:
  --help       display this help text and exit
  --version    display version and exit

Commands:
  info [options] <pkgs...>
    check if package exists and list available actions
    -s, --scan    also check package is installed ok
    -a, --all     display info for every known package
'


main() {
  setDefaults
  while getPreCmdOpt; do :; done
  getCmd
  "args_$command"
  "run_$command"
}

###### Command Implementations ######

libdir="$HOME/lib/will"
datadir="${XDG_DATA_DIR:-$HOME/.local/share}/will"
logdir="$datadir/logs"
checkscript=check.sh
collectionfile=collection
alternatesfile=alternates
installscript=install
installDepsfile=deps-up
runDepsfile=deps
submodulelist=manifest

# TODO: update contents of the will lib folder based on a repos file
# while IFS= read -r LINE || [[ -n "$LINE" ]]; do
#   echo "$LINE"
# done <"$HOME/.will/repos"

run_info() {
  local exitCode=0
  if [[ -n "$all" ]]; then
    cd "$libdir"
    for pkg in *; do
      run_info1 "$pkg" || :
    done
    exit 0
  else
    for pkg in "${pkgs[@]}"; do
      run_info1 "$pkg" || exit "$?"
    done
  fi
}
run_info1() {
  local pkg="$1"
  if [[ -d "$libdir/$pkg" ]]; then
    local ok check collection alternates up down installDeps runDeps submodules
    local extraOutput=''
    # Q: is there the ability to check the install?
    check="$([[ -f "$libdir/$pkg/$checkscript" ]] && echo ' check')"
    # Q: Is this a collection or alternates package?
    collection="$([[ -f "$libdir/$pkg/$collectionfile" ]] && echo ' collection')"
    alternates="$([[ -f "$libdir/$pkg/$alternatesfile" ]] && echo ' alternates')"
    # Q: does this module have submodules?
    submodules="$([[ -f "$libdir/$pkg/$submodulelist" ]] && echo ' submodules')"
    if [[ -n "$scan" ]]; then
      if [[ -n "$check" ]]; then
    # Q: when scanning and can check, report install status
        local exitCode=0
        extraOutput+="$(run_check1 "$pkg" 2>&1)"
        exitCode="$?"
        if [ $exitCode -eq 0 ]; then
          ok=" $(guardTput setaf 2)OK$(guardTput sgr0)"
        else
          ok=" $(guardTput bold)$(guardTput setaf 1)NO$(guardTput sgr0)"
        fi
      elif [[ -n "$collection" ]]; then
        local missing=''
        while IFS= read -r line || [[ -n "$line" ]]; do
          line="$(echo "$line" | sed -e 's/^\s*//' -e 's/\s*$//')"
          case "$line" in
            ''|'#'*) continue ;;
            *)
              if ! run_check1 "$line" 2>/dev/null; then
                missing+=" $line"
              fi
            ;;
          esac
        done <"$libdir/$pkg/$collectionfile"
        if [[ -z "$missing" ]]; then
          ok=" $(guardTput setaf 2)OK$(guardTput sgr0)"
        else
          ok=" $(guardTput bold)$(guardTput setaf 1)NO$(guardTput sgr0)"
          extraOutput+="packages missing:$missing"
        fi
      elif [[ -n "$alternates" ]]; then
        die "unimplemented: alternates packages"
      else
        ok=" $(guardTput setaf 6)--$(guardTput sgr0)"
      fi
    fi
    # Q: is there an install script?
    up="$([[ -x "$libdir/$pkg/$installscript" ]] && echo ' up')"
    # TODO Q: is there an install log for uninstalling?
    # Q: are there any dependencies?
    installDeps="$([[ -f "$libdir/$pkg/$installDepsfile" ]] && echo ' deps.up')"
    runDeps="$([[ -f "$libdir/$pkg/$runDepsfile" ]] && echo ' deps.run')"

    echo "$pkg$ok$check$collection$alternates$up$down$runDeps$installDeps$submodules"
    if [ -n "$extraOutput" ]; then
      sed 's/^/  /' <(echo "$extraOutput") >&2
    fi
    # recurse into submodules if we're scanning with recursion on
    if [[ -n "$submodules" && -n "$scan" && -n "$recursive" ]]; then
      while IFS= read -r line || [[ -n "$line" ]]; do
        line="$(echo "$line" | sed -e 's/^\s*//' -e 's/\s*$//')"
        case "$line" in
          ''|'#'*) continue ;;
          *)
            run_info1 "$pkg/$line"
          ;;
        esac
      done <"$libdir/$pkg/$submodulelist"
    fi
    return 0
  else
    return 1
  fi
}

run_check() {
  for pkg in "${pkgs[@]}"; do
    if [[ ! -e "$libdir/$pkg/$checkscript" ]]; then
      die "no check script for '$pkg'"
    fi
    run_check1 "$pkg" || die
  done
}
run_check1() {
  local pkg="$1"
  if [[ ! -e "$libdir/$pkg/$checkscript" ]]; then
    return 1
  fi
  (
    cd "$libdir/$pkg"
    exec sh "$checkscript"
  ) >/dev/null
  return "$?"
}

run_up() {
  local exitCode okPkgs failPkgs
  local pkg
  for pkg in "${pkgs[@]}"; do
    run_up1 "$pkg"
    exitCode="$?"
    if [[ "$exitCode" -eq 0 ]]; then
      okPkgs+=" $pkg"
    else
      failPkgs+=" $pkg"
    fi
  done
  if [[ "$okPkgs" -ne 0 ]]; then echo >&2 "the following packages installed successfully:$okPkgs"; fi
  if [[ "$failPkgs" -ne 0 ]]; then die "[ERROR] the following packages failed to install:$failPkgs"; fi
}
run_up1() {
  local pkg=$1
  local exitCode
  # the package must be installable
  if [[ ! -x "$libdir/$pkg/$installscript" ]]; then
    echo >&2 "no install script for '$pkg'"
    return 1
  fi
  # the package must be checkable
  if [[ ! -f "$libdir/$pkg/$checkscript" ]]; then
    echo >&2 "no check script for '$pkg'"
    return 1
  fi
  # skip if already available
  if run_check1 "$pkg"; then
    echo >&2 "skipping already-up package '$pkg'"
    return 0
  fi
  # warn about any missing install-time dependencies, but carry on even if missing
  if [[ -f "$libdir/$pkg/$installDepsfile" ]]; then
    local dep
    while IFS= read -r dep || [[ -n "$dep" ]]; do
      dep="$(echo "$dep" | sed -e 's/^\s*//' -e 's/\s*$//')"
      case "$dep" in
        ''|'#'*) continue ;;
        *)
          run_check1 "$dep" || echo >&2 "$(guardTput bold)$(guardTput setaf 3)[WARN]$(guardTput sgr0) will $pkg: missing install dependency: $dep"
        ;;
      esac
    done <"$libdir/$pkg/$installDepsfile"
  fi
  mkdir -p "$logdir/$pkg"
  (
    cd "$libdir/$pkg"
    # NOTE the following redirects are informed by https://serverfault.com/a/63708
    exec "./$installscript" 3>&1 1>"$logdir/$pkg/installed-files.log" 2>&3 | tee "$logdir/$pkg/error.log" >&2
  )
  # make sure the install script succeeded
  exitCode="$?"
  if [[ "$exitCode" -ne 0 ]]; then return "$exitCode"; fi
  # make sure the install script made the package available
  if ! run_check1 "$pkg"; then
    echo >&2 "install script did not bring up '$pkg'"
    return 1
  fi
  # warn about any missing run-time dependencies, but carry on even if missing
  if [[ -f "$libdir/$pkg/$runDepsfile" ]]; then
    local dep
    while IFS= read -r dep || [[ -n "$dep" ]]; do
      dep="$(echo "$dep" | sed -e 's/^\s*//' -e 's/\s*$//')"
      case "$dep" in
        ''|'#'*) continue ;;
        *)
          run_check1 "$dep" || echo >&2 "$(guardTput bold)$(guardTput setaf 3)[WARN]$(guardTput sgr0) will $pkg: missing runtime dependency: $dep"
        ;;
      esac
    done <"$libdir/$pkg/$runDepsfile"
  fi
}


###### Parse Arguments ######

# Variables set:
#   $color: boolean, default on if output is a terminal; also set by -C,--color, cleared by --no-color
#
#   $command: by getCmd
#   $pkgs[]: list of packages to operate on
#   $pkg: package to operate on (if only one is allowed)
#
#   $all: boolean, default off
#   $scan: boolean, default off
#   $recursive: boolean, default off

setDefaults() {
  if [ -t 1 ]; then
    color=1
  fi
}

getPreCmdOpt() {
  if [[ "${#args[@]}" -eq 0 ]]; then return 1; fi
  local arg="${args[0]}"
  case "$arg" in
    -C|--color) color=1 ;;
    --no-color) color= ;;
    --help)
      echo "$usage"
      exit 0
    ;;
    --version)
      echo "will v$version"
      exit 0
    ;;
    -*)
      die "unknown option '$arg'"
    ;;
    *) return 1;;
  esac
  args=("${args[@]:1}")
}

getCmd() {
  if [[ "${#args[@]}" -eq 0 ]]; then
    die "command required"
  fi
  local arg="${args[0]}"
  case "$arg" in
    check|info|up)
      command=$arg
      ;;
    *) die "unknown command '$arg'"
  esac
  args=("${args[@]:1}")
}


args_check() {
  pkgs=("${args[@]}")
  args=()
}
args_info() {
  while [[ "${#args[@]}" -gt 0 ]]; do
    popArg
    case "$arg" in
      -a|--all) all=1 ;;
      -r|--recursive) recursive=1 ;;
      -s|--scan) scan=1 ;;
      -*)
        die "unrecognized info option '$arg'"
      ;;
      *)
        pkgs=("${pkgs[@]}" "$arg")
      ;;
    esac
  done
}
args_up() {
  pkgs=("${args[@]}")
  args=()
}

popArg() {
  arg="${args[0]}"
  args=("${args[@]:1}")
  if [[ "$arg" =~ ^(-[^-])(.+)$ ]]; then
    arg="${BASH_REMATCH[1]}"
    args=( "-${BASH_REMATCH[2]}" "${args[@]}" )
  fi
}

###### Helpers ######

guardTput() {
  if [[ -n "$color" ]]; then tput "$@"; fi
}

dieUsage() {
  echo >&2 "$usage"
  exit 0
}
dieVersion() {
  echo "$version"
}

die() {
  if [[ -n "$1" ]]; then echo >&2 "$1"; fi
  exit 1
}

###### Run the Program ######

args=("$@")
main
