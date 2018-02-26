# Renders LICENSE text file into html
build_home_license <- function(pkg, path) {
  license_path <- file.path(pkg$path, "LICENSE")
  if (!file.exists(license_path)) {
    return()
  }

  render_page(pkg, "license",
    data = list(
      pagetitle = "License",
      license = read_file(license_path)
    ),
    path = file.path(path, "LICENSE.html")
  )
}

data_home_sidebar_license <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  paste0(
    "<h2>License</h2>\n",
    "<p>", autolink_license(pkg$desc$get("License")[[1]]), "</p>\n"
  )
}

# helpers -----------------------------------------------------------------

autolink_license <- function(x) {
  db <- licenses_db()

  for (i in seq_len(nrow(db))) {
    match <- paste0("\\b\\Q", db$abbr[[i]], "\\E\\b")
    x <- gsub(match, db$a[[i]], x, perl = TRUE)
  }
  x
}

licenses_db <- function() {
  path <- file.path(R.home("share"), "licenses", "license.db")
  db <- tibble::as_tibble(read.dcf(path))

  abbr <- ifelse(is.na(db$SSS), db$Abbrev, db$SSS)
  url <- db$URL

  # Add entry for LICENSE file
  abbr <- c(abbr, "LICENSE")
  url <- c(url, "LICENSE.html")

  out <- tibble::tibble(abbr, url)
  out$a <- paste0("<a href='", url, "'>", abbr, "</a>")

  out[!is.na(out$abbr), ]
}
