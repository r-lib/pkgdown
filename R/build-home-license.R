licenses_db <- function() {
  path <- file.path(R.home("share"), "licenses", "license.db")
  db <- tibble::as_tibble(read.dcf(path))

  abbr <- ifelse(is.na(db$SSS), db$Abbrev, db$SSS)
  url <- db$URL

  # Add entry for LICENSE file
  abbr <- c(abbr, "LICENSE")
  url <- c(url, "LICENSE")

  out <- tibble::tibble(abbr, url)
  out[!is.na(out$abbr), ]
}

autolink_license <- function(x) {
  db <- licenses_db()
  db$a <- paste0("<a href='", db$url, "'>", db$abbr, "</a>")

  for (i in seq_len(nrow(db))) {
    match <- paste0("\\b\\Q", db$abbr[[i]], "\\E\\b")
    x <- gsub(match, db$a[[i]], x, perl = TRUE)
  }
  x
}


