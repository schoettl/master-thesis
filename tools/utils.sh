
# $1: awk address
printIndentation() {
    awk "$1"'{ print gensub(/^([ \t]*).*/, "\\1", 1) }'
}

removeOneJavaIndentLevel() {
    sed -r 's/^(\t|    )//'
}

removeIndentation() {
    declare indent tempFile
    tempFile=$(mktemp)
    cat > "$tempFile"
    indent=$(printIndentation 'NR==1' < "$tempFile")
    sed -r "s/^$indent//" < "$tempFile"
}
