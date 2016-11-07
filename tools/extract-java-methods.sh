#!/bin/bash
# Extract n Java methods with implementation
# Usage: $0 <method-name> <number-of-methods> <java-file>

readonly PROGDIR=$(dirname "$(readlink -m "$0")")

source "$PROGDIR"/utils.sh

main() {
    declare methodName=$1
    declare count=$2
    declare filename=$3

    awk "/$methodName\(.*\{/{n=0; s=1}; s{print}; /^(\t|    )}/{n++}; s&&n>=$count{exit}" "$filename" \
        | removeOneJavaIndentLevel
}

main "$@"
