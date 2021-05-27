.onAttach <- function(libname, pkgname) {
  packageStartupMessage("Be aware that in this version of the FFdownload-Package I have renamed the output dataset to 'FFdata',
                        and the input variable for temporary directories to 'tempd'. This might break old code.")
}
