#!/bin/bash
# Convert a CSV file to a LaTeX table

printUsage() {
    cat <<EOF
usage: $PROGNAME <input-field-sep> <columns>

<columns> must be a list of field numbers, e.g. 1,2,5
EOF
}

readonly PROGNAME=$(basename "$0")

# $1: error message
exitWithError() {
    echo "$1" >&2
    exit 1
}

main() {
    (( $# == 2 )) || exitWithError "$(printUsage)"
    declare inputFieldSep=$1
    declare columns=$2
    declare printArgs=\$${columns//,/, $}

    awk -F "$inputFieldSep" 'BEGIN {OFS=" & "; ORS=" \\\\\n"}; '"{print $printArgs}"
}

main "$@"
