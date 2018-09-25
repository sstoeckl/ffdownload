#' @title Converter to read downloaded datasets and automatically put them into one large dataframe with xts
#'
#' @description \code{converter} read/clean/write
#'
#' @param file downloaded dataset
#'
#' @return list of annual/monthly/daily files
#'
#' @importFrom stats na.omit
#' @importFrom utils download.file read.csv unzip
#' @import xts rvest
#' @importFrom zoo as.yearmon
#'
converter <- function(file) {
  data <- readLines(file)

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
  if (class(datatest) == "try-error") {
    datatest <- lapply(l, function(x) na.omit(read.csv(text = x,  stringsAsFactors = FALSE, header = FALSE)))
  }
  datatest <- datatest[sapply(datatest, nrow) > 0]

  d <- vector()
  for (i in 1:length(datatest)) d[i] <- nchar(as.character(datatest[[i]]$X[1])) == 8
  for (i in 1:length(datatest)) d[i] <- nchar(as.character(datatest[[i]][1,1])) == 8
  m <- vector()
  for (i in 1:length(datatest)) m[i] <- nchar(as.character(datatest[[i]]$X[1])) == 6
  for (i in 1:length(datatest)) m[i] <- nchar(as.character(datatest[[i]][1,1])) == 6
  a <- vector()
  for (i in 1:length(datatest)) a[i] <- nchar(as.character(datatest[[i]]$X[1])) == 4
  for (i in 1:length(datatest)) a[i] <- nchar(as.character(datatest[[i]][1,1])) == 4

  annual  <- lapply(datatest[unlist(a)], function(x) xts::xts(as.data.frame(lapply(x[,-1,drop=FALSE],as.numeric)), order.by = as.yearmon(as.character(x[, 1]), format = "%Y")) )
  monthly <- lapply(datatest[unlist(m)], function(x) xts::xts(as.data.frame(lapply(x[,-1,drop=FALSE],as.numeric)), order.by = as.yearmon(as.character(x[, 1]), format = "%Y%m")))
  daily <- lapply(datatest[unlist(d)], function(x) xts::xts(as.data.frame(lapply(x[,-1,drop=FALSE],as.numeric)), order.by = as.Date(as.character(x[, 1]), format = "%Y%m%d")))


  return(list(annual = annual, monthly = monthly, daily = daily))

}


