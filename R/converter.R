#' @title Converter to read downloaded datasets and automatically put them into one large dataframe with xts
#'
#' @description \code{converter} read/clean/write
#'
#' @param file downloaded dataset
#' @param na_values numeric vector of sentinel values to replace with \code{NA} after parsing.
#' Default \code{NULL} performs no replacement (original behaviour).
#'
#' @return list of annual/monthly/daily files
#'
#' @importFrom stats na.omit
#' @importFrom utils download.file read.csv unzip
#' @import xts rvest
#' @importFrom zoo as.yearmon
#'
converter <- function(file, na_values = NULL) {
  data <- readLines(file)

  # replace commas at line ends (case Momentum)
  data <- gsub(",$", "",gsub(",$", "", data))

  data[1] <- paste0(data[1],",")

  index <- grep(",", data)
  new_index <- sort(unique(c(index - 1, index)))

  headers <- new_index[!(new_index %in% index)]
  headers1 <- headers + 1
  headers2 <- c(headers[-1] - 1,  max(new_index))
  headers_names <- headers; headers_names[1] <- 1

  l <- mapply(function(x, y) data[x:y], headers1, headers2, SIMPLIFY = FALSE)

  names <- gsub("(.*) -- .*",  "\\1" , trimws(data[headers_names]))
  names <- tolower(gsub(" ", "_", names))

  if(any(names == "average_market_cap")) {
    other <- (which(names == "average_market_cap") + 1):length(headers)
    headers[other] <- paste0(headers[other] - 5, ":", headers[other])

    names <- vector()
    for(i in seq_along(headers)) names[i] <- gsub("(.*) -- .*",  "\\1" , paste0( trimws( data[eval(parse(text = headers[i]))]),collapse = "" ))
    names <- tolower(gsub(" ", "_", names))

  }

  if(any(names == "")){for (i in 1:length(names)){if(names[i]==""){names[i] <- paste0("Temp",i)}}}

  names(l) <- names

  datatest <- try(lapply(l[2:length(l)], function(x) na.omit(read.csv(text = x,  stringsAsFactors = FALSE, skip=0))), silent = TRUE)
  if (inherits(datatest, "try-error")) {
    datatest <- lapply(l, function(x) na.omit(read.csv(text = x,  stringsAsFactors = FALSE, header = FALSE)))
  }
  datatest <- datatest[sapply(datatest, nrow) > 0]

  d <- vector()
  for (i in 1:length(datatest)) d[i] <- nchar(as.character(datatest[[i]]$X[1])) == 8
  for (i in 1:length(datatest)) d[i] <- nchar(as.character(datatest[[i]][1,1])) == 8
  # in case this is true, check if it only contains numbers (a daily date should do so)
  for (i in 1:length(datatest)) if(d[i]){d[i] <- grepl("^[[:digit:]]+$", datatest[[i]][1,1])}

  m <- vector()
  for (i in 1:length(datatest)) m[i] <- nchar(as.character(datatest[[i]]$X[1])) == 6
  for (i in 1:length(datatest)) m[i] <- nchar(as.character(datatest[[i]][1,1])) == 6
  # in case this is true, check if it only contains numbers (a daily date should do so)
  for (i in 1:length(datatest)) if(m[i]){m[i] <- grepl("^[[:digit:]]+$", datatest[[i]][1,1])}

  a <- vector()
  for (i in 1:length(datatest)) a[i] <- nchar(as.character(datatest[[i]]$X[1])) == 4
  for (i in 1:length(datatest)) a[i] <- nchar(as.character(datatest[[i]][1,1])) == 4
  # in case this is true, check if it only contains numbers (a daily date should do so)
  for (i in 1:length(datatest)) if(a[i]){a[i] <- grepl("^[[:digit:]]+$", datatest[[i]][1,1])}

  annual  <- lapply(datatest[unlist(a)], function(x) xts::xts(as.data.frame(lapply(x[,-1,drop=FALSE],as.numeric)), order.by = as.yearmon(paste0(as.character(x[, 1]),"12"), format = "%Y%m")) )
  monthly <- lapply(datatest[unlist(m)], function(x) xts::xts(as.data.frame(lapply(x[,-1,drop=FALSE],as.numeric)), order.by = as.yearmon(as.character(x[, 1]), format = "%Y%m")))
  daily   <- lapply(datatest[unlist(d)], function(x) xts::xts(as.data.frame(lapply(x[,-1,drop=FALSE],as.numeric)), order.by = as.Date(as.character(x[, 1]), format = "%Y%m%d")))

  # Replace sentinel values with NA if requested
  if (!is.null(na_values)) {
    replace_sentinels_xts <- function(x) { x[x %in% na_values] <- NA; x }
    annual  <- lapply(annual,  replace_sentinels_xts)
    monthly <- lapply(monthly, replace_sentinels_xts)
    daily   <- lapply(daily,   replace_sentinels_xts)
  }

  return(list(annual = annual, monthly = monthly, daily = daily))
}

#' @title Converter to read downloaded datasets and automatically put them into one large dataframe as tibbles
#'
#' @description \code{converter_tbl} read/clean/write
#'
#' @param file downloaded dataset
#' @param na_values numeric vector of sentinel values to replace with \code{NA} after parsing.
#' Default \code{NULL} performs no replacement (original behaviour).
#'
#' @return list of annual/monthly/daily files
#'
#' @importFrom stats na.omit
#' @importFrom utils download.file read.csv unzip
#' @import xts rvest
#' @importFrom zoo as.yearmon
#' @importFrom timetk tk_tbl
#'
converter_tbl <- function(file, na_values = NULL) {
  data <- readLines(file)

  # replace commas at line ends (case Momentum)
  data <- gsub(",$", "",gsub(",$", "", data))

  data[1] <- paste0(data[1],",")

  index <- grep(",", data)
  new_index <- sort(unique(c(index - 1, index)))

  headers <- new_index[!(new_index %in% index)]
  headers1 <- headers + 1
  headers2 <- c(headers[-1] - 1,  max(new_index))
  headers_names <- headers; headers_names[1] <- 1

  l <- mapply(function(x, y) data[x:y], headers1, headers2, SIMPLIFY = FALSE)

  names <- gsub("(.*) -- .*",  "\\1" , trimws(data[headers_names]))
  names <- tolower(gsub(" ", "_", names))

  if(any(names == "average_market_cap")) {
    other <- (which(names == "average_market_cap") + 1):length(headers)
    headers[other] <- paste0(headers[other] - 5, ":", headers[other])

    names <- vector()
    for(i in seq_along(headers)) names[i] <- gsub("(.*) -- .*",  "\\1" , paste0( trimws( data[eval(parse(text = headers[i]))]),collapse = "" ))
    names <- tolower(gsub(" ", "_", names))

  }

  if(any(names == "")){for (i in 1:length(names)){if(names[i]==""){names[i] <- paste0("Temp",i)}}}

  names(l) <- names

  datatest <- try(lapply(l[2:length(l)], function(x) na.omit(read.csv(text = x,  stringsAsFactors = FALSE, skip=0))), silent = TRUE)
  if (inherits(datatest, "try-error")) {
    datatest <- lapply(l, function(x) na.omit(read.csv(text = x,  stringsAsFactors = FALSE, header = FALSE)))
  }
  datatest <- datatest[sapply(datatest, nrow) > 0]

  d <- vector()
  for (i in 1:length(datatest)) d[i] <- nchar(as.character(datatest[[i]]$X[1])) == 8
  for (i in 1:length(datatest)) d[i] <- nchar(as.character(datatest[[i]][1,1])) == 8
  # in case this is true, check if it only contains numbers (a daily date should do so)
  for (i in 1:length(datatest)) if(d[i]){d[i] <- grepl("^[[:digit:]]+$", datatest[[i]][1,1])}

  m <- vector()
  for (i in 1:length(datatest)) m[i] <- nchar(as.character(datatest[[i]]$X[1])) == 6
  for (i in 1:length(datatest)) m[i] <- nchar(as.character(datatest[[i]][1,1])) == 6
  # in case this is true, check if it only contains numbers (a daily date should do so)
  for (i in 1:length(datatest)) if(m[i]){m[i] <- grepl("^[[:digit:]]+$", datatest[[i]][1,1])}

  a <- vector()
  for (i in 1:length(datatest)) a[i] <- nchar(as.character(datatest[[i]]$X[1])) == 4
  for (i in 1:length(datatest)) a[i] <- nchar(as.character(datatest[[i]][1,1])) == 4
  # in case this is true, check if it only contains numbers (a daily date should do so)
  for (i in 1:length(datatest)) if(a[i]){a[i] <- grepl("^[[:digit:]]+$", datatest[[i]][1,1])}

  annual  <- lapply(datatest[unlist(a)], function(x) timetk::tk_tbl(xts::xts(as.data.frame(lapply(x[,-1,drop=FALSE],as.numeric)), order.by = as.yearmon(paste0(as.character(x[, 1]),"12"), format = "%Y%m")), rename_index = "date", silent = TRUE) )
  monthly <- lapply(datatest[unlist(m)], function(x) timetk::tk_tbl(xts::xts(as.data.frame(lapply(x[,-1,drop=FALSE],as.numeric)), order.by = as.yearmon(as.character(x[, 1]), format = "%Y%m")), rename_index = "date", silent = TRUE) )
  daily   <- lapply(datatest[unlist(d)], function(x) timetk::tk_tbl(xts::xts(as.data.frame(lapply(x[,-1,drop=FALSE],as.numeric)), order.by = as.Date(as.character(x[, 1]), format = "%Y%m%d")), rename_index = "date", silent = TRUE) )

  # Replace sentinel values with NA if requested (only numeric columns, leaving date column intact)
  if (!is.null(na_values)) {
    replace_sentinels_tbl <- function(tbl) {
      tbl[] <- lapply(tbl, function(col) {
        if (is.numeric(col)) col[col %in% na_values] <- NA
        col
      })
      tbl
    }
    annual  <- lapply(annual,  replace_sentinels_tbl)
    monthly <- lapply(monthly, replace_sentinels_tbl)
    daily   <- lapply(daily,   replace_sentinels_tbl)
  }

  return(list(annual = annual, monthly = monthly, daily = daily))
}
