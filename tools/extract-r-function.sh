#!/bin/bash
# Extract a R function with implementation
# Usage: $0 <function-name> <r-file>

readonly PROGDIR=$(dirname "$(readlink -m "$0")")

source "$PROGDIR"/utils.sh

main() {
    declare functionName=$1
    declare filename=$2

    awk "/^$functionName *= *function\(/,/^}/" "$filename"
}

main "$@"
