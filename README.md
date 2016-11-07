Master's thesis
===============

Compile
-------

To compile the PDF document:

```
make
```

Or, to compile it with tikz (for great vector graphic plots with LaTeX fonts):

```
make clean && make USE_TIKZ=1
```

Another option for make is `BOOK_PRINT`:

```
touch thesis.Rtex && make BOOK_PRINT=1
```

This causes roman page numbering for the first few pages and arabic page
numbering for the content pages.

Dependencies
------------

Arch (system) dependencies

- latex
- tcl
- tk
- java
- umlet
- emacs with Org mode
- (pandoc?)
- (pdftk?)

R dependencies, install in R with `install.packages("packagename")`

- knitr
- ggplot2
- dplyr
- tikzDevice
# master-thesis
