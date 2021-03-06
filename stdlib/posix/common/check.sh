#!/bin/sh
set -e

. ../scripts/tools.sh


exec ../scripts/check.sh \
  $languageTools \
  $filesystemTools \
  $miscTools \
  $textTools \
  $processTools \
  $buildTools \
  $adminTools \
  $terminalTools
