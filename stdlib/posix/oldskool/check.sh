#!/bin/sh
set -e

. ../scripts/tools.sh


exec ../scripts/check.sh \
  $zipTools \
  $commsTools \
  $uuTools
