# Renders LICENSE text file into html
build_home_license <- function(pkg) {
  license_md <- path_first_existing(pkg$src_path, c("LICENSE.md", "LICENCE.md"))
  if (!is.null(license_md)) {
    render_md(pkg, license_md)
  }

  license_raw <- path_first_existing(pkg$src_path, c("LICENSE", "LICENCE"))
  if (!is.null(license_raw)) {
    render_page(pkg, "title-body",
      data = list(
        pagetitle = tr_("License"),
        body = paste0("<pre>", escape_html(read_file(license_raw)), "</pre>")
      ),
      path = "LICENSE-text.html"
    )
    return()
  }
}

data_home_sidebar_license <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  link <- autolink_license(pkg$desc$get_field("License", ""))

  license_md <- path_first_existing(pkg$src_path, c("LICENSE.md", "LICENCE.md"))
  if (!is.null(license_md)) {
    link <- c(
      a(tr_("Full license"), "LICENSE.html"),
      paste0("<small>", link, "</small>")
    )
  }

  sidebar_section(tr_("License"), link)
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
  path <- path(R.home("share"), "licenses", "license.db")
  db <- tibble::as_tibble(read.dcf(path))

  db <- add_missing_sss(db)

  abbr <- ifelse(is.na(db$SSS), db$Abbrev, db$SSS)
  url <- db$URL

  # Add entry for LICENSE file
  abbr <- c(abbr, "LICENSE", "LICENCE")
  url <- c(url, "LICENSE-text.html", "LICENSE-text.html")

  out <- tibble::tibble(abbr, url)
  out$a <- paste0("<a href='", url, "'>", abbr, "</a>")

  out[!is.na(out$abbr), ]
}

# Add missing standard short specification (SSS) for some licenses
# (e.g., Mozilla Public Licences)
# see src/library/tools/R/license.R in R source for details
add_missing_sss <- function(db) {
  needs_sss <- !is.na(db$Abbrev) & !is.na(db$Version) & is.na(db$SSS)
  x <- db[needs_sss, ]

  db[needs_sss, "SSS"] <- paste0(x$Abbrev, "-", x$Version)

  db
}
