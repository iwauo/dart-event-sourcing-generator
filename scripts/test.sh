#!/usr/bin/env bash
set -e
SCRIPT_DIR=$(cd $"${BASH_SOURCE%/*}" && pwd)
BASE_DIR=$(cd $SCRIPT_DIR && cd .. && pwd)

set -x
(
  cd $BASE_DIR &&
  dartfmt -w . &&
  pub get &&
  pub run test
)
