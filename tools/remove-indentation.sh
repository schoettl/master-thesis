#!/bin/bash
# Remove indentation so that the first of code line starts at column 0

readonly PROGDIR=$(dirname "$(readlink -m "$0")")

source "$PROGDIR"/utils.sh

removeIndentation
