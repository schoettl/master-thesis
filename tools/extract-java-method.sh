#!/bin/bash
# Extract a Java method with implementation
# Usage: $0 <method-name> <java-file>

readonly PROGDIR=$(dirname "$(readlink -m "$0")")

source "$PROGDIR"/utils.sh

main() {
    declare methodName=$1
    declare filename=$2

    awk "/$methodName\(.*\{/,/^(\t|    )}/" "$filename" \
        | removeOneJavaIndentLevel
}

main "$@"
