#!/bin/bash
# Skip lines between start (exclusive) and end (inclusive) and insert ellipsis
# Usage: $0 <start-line-exclusive> <end-line-inclusive>

readonly PROGDIR=$(dirname "$(readlink -m "$0")")

source "$PROGDIR"/utils.sh

declare startExclusive=$1
declare endInclusive=$2

if [[ -z $startExclusive || -z $endInclusive ]]; then
    echo "error: wrong arguments"
    exit 1
fi

declare inputFile
inputFile=$(mktemp)
cat > "$inputFile"

declare startInclusive indentation
startInclusive=$(awk "f{print; exit}; /$startExclusive/{f=1}" < "$inputFile")

if [[ -z $startInclusive ]]; then
    echo "error: could not find given start"
    exit 1
fi

indentation=$(printIndentation "/$startExclusive/" < "$inputFile")

cat "$inputFile" | \
sed "/$startInclusive/,/$endInclusive/ d" | \
sed "/$startExclusive/ a\\
$indentation..."
