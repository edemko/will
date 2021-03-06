# POSIX

This package is broken up into several sub-packages.
Strict posix compliance can be checked by examining the `posix` package directly.
However, many tools are not really needed in certain contexts (`lex`/`yacc`, `batch`), or have been superseded (`compress`, `uucp`, `mailx`).


## Maintenence

The `./scripts/check.sh <commands...>` command handles the job of checking that each command is present;
  sub-modules should defer to that script.
The `./scripts/tools.sh` contains a list of all the POSIX commands, broken out into several variables.
Having these in one place facilitates re-categorizing commands by often only requiring edits to a single file.
As long as no new variables are defined in `tools.sh`, this package group will work as expected.
Once a new variable is added, that variable should be included in one of the existing sub-packages, or a new sub-package should be made to test for them.
If a new sub-package must be added, be sure to include it in the `posix` package's `collection` file.
