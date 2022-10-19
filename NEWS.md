# FFdownload 1.1

* Resubmit to CRAN
* Added possibility to create list of tibbles rather than list of xts

# FFdownload 1.0.6

* Resubmit to CRAN
* Corrected variable names to not be similar to a corresponding command (FFdownload -> FFdata, tempdir -> tempd). This is potentially a breaking change, so I additionally included a warning message when the package is loaded.
* Also corrected date in converter for annual data to Dec of each year.
* Additionally fixed the download/download_only problem which now should be working

# FFdownload 1.0.5

* Resubmit to CRAN
* Fixed too long line in commented example

# FFdownload 1.0.4

* Resubmit to CRAN
* wraped examples that download in `donttest{}` but because cran tests this anyway (see https://stackoverflow.com/questions/63693563/issues-in-r-package-after-cran-asked-to-replace-dontrun-by-donttest) I also commented the second example which takes some time out (as `dontrun()` seems to also not being liked on cran)

# FFdownload 1.0.3

* Resubmit to CRAN

# FFdownload 1.0.2

* Added a `NEWS.md` file to track changes to the package.
* Added slight changes suggested by CRAN
