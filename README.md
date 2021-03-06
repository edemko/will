# sysup

You log into a box.
Are your favorite utilities/programs available?
Do you remember how to install them?
Can you pester your sysadmin to install them all?
Can you install them without privileges?
Who actually wants to answer all these questions themselves?

Sysup is not a package manager, but it can be taught how to check for available tools and install them preferably as an unprivileged user, all in a very minimal (i.e. portable) environment.
If you need to write your own packages, it's incredibly simple:
  I've built it in shell just to force me to keep it simple.

## Get Started

Install like so:
```
wget -q 'https://raw.githubusercontent.com/Zankoku-Okuno/sysup/master/bin/sysupup.sh' -O - | sh
```
If you don't trust it, read the source first: it's only a handful of lines of `sh`.
By default, it installs to `~/bin`, but you can change that by exporting `SYSUP_BINDIR`.

  * `sysup info -a` to see what packages are known.
  * `sysup info -as` to check availability of each package's utilities, file structures, versions, and so on.
  * `sysup up <pkg names...>` to install packages (if possible)

You can also throw a `-C` flag at `sysup` and pipe to `less -R` to (e.g. `sysup -C info -sar | less -R`).

Sysup is not a package manager.
It can check for the existence of things (something like autoconf), but it doesn't care where they came from.
It can run install scripts, but it doesn't keep the strictest track of 
It can warn you about missing dependencies, but it won't solve any dependency problems for you.
Really, it's more like an executable form of notes about how you set up your box(en).

## Concepts

So far, I only have

  * package: a unit that can manage a simple utility

but I expect I'll have repositories and sources soon enough.

## Commands

  * `check <PKGS...>`: check that all of the passed packaged utilities are available
  * `info [PKGS...]`: detect capabilities of the passed packages.
    Options include `-a`/`--all` to examine all known top-level packages, `-r`/`--recursive` to examine sub-packages when `-a`, and `-s`/`--scan` to also check availability as in the `check` command.

## Package Format

A package is a folder containing some files.

Since packages are just folders, we can put one packages inside another, in which case we have a sub-package.
Sub-packages are great for managing different versions/vendors of a utility.
Just because a package contains sub-packages doesn't mean that the super-package can't be a full package in and of itself.

The files you can place into a package are the following (all of these are optional)

  * `check.sh`: a Bourne shell script that should exit successfully only if the package utility is available, no matter how it was installed.
    Note that this will be executed with `sh $pkg/check.sh`, so it need not be executable, but also be aware that `sh` might not link to `bash` on all your systems!
    The `pwd` will be the same as the package folder.
  * `collection` and `alternates`: a package might delgate itself entirely to other packages.
    If a `collection` file is present, all packages listed there (one per line) must be OK for this package to report OK.
    An `alternates` file operates the same, but reports OK when _any_ listed package is OK.
    A package should only have one of `check.sh`, `collection`, or `alternates` included.
  * `install`: an executable that can install a package.
    The environment variable `$SYSUP_GLOBAL` is set to `1` if the install should be system-wide or empty for local (i.e. the current user only).
    The `pwd` will be the same as the package folder.
    Every file/folder that should be removed during uninstallation should be printed to stdout, one per line, preceded by a prefix:
      one of `[FILE] `, `[DIR] `, or `[DIR -r] ` (note the trailing space).
    These prefixes allow misbehaving commands from install scripts to have their output ignored while still finding the file list in the output.
    (FIXME: and the order should be as installed, then the uninstall script can just operate in reverse order)
  * `manifest`: a file explicitly listing sub-packages, one sub-package per line.
    Spaces at the start/end of a line are ignored, as are blank lines and lines that begin with a hash `#`.
    This is used when scanning recursively to determine which sub-folders are actually expected to contain a package.
  * Any other file/folder can be included as well.
    This can provide (e.g.) install files, helper scripts, additional documentation, and so on.
