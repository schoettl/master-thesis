#!/bin/bash
# Convert UMLet file to vector graphic
# Usage: $0 <umlet-filename>

main() {
    declare filename=$1
    declare outFormat=eps
    declare outFilename=${filename%.uxf}.$outFormat

	umlet -action=convert -format="$outFormat" -filename="$filename" -output="$outFilename"
}

main "$@"
