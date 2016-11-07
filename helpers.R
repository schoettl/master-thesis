
isSet = function(val) {
    if (is.character(val))
        return(val != '')
    return(as.logical(val))
}
ifdef = function(name) {
    var = Sys.getenv(name)
    isSet(var)
}
