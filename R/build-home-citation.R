
has_citation <- function(path = ".") {
  file_exists(path(path, 'inst/CITATION'))
}

create_citation_meta <- function(path) {
  path <- path(path, "DESCRIPTION")

  dcf <- read.dcf(path)
  meta <- as.list(dcf[1, ])

  if (!is.null(meta$Encoding)) {
    meta <- lapply(meta, iconv, from = meta$Encoding, to = "UTF-8")
  } else {
    meta$Encoding <- "UTF-8"
  }

  meta
}

read_citation <- function(path = ".") {
  if (!has_citation(path)) {
    return(character())
  }
  meta <- create_citation_meta(path)
  cit_path <- path(path, 'inst/CITATION')

  utils::readCitationFile(cit_path, meta = meta)
}

data_home_sidebar_citation <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  sidebar_section(
    heading = "Citation",
    bullets = a(sprintf(tr_("Citing %s"), pkg$package), "authors.html#citation")
  )
}

data_citations <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  if (has_citation(pkg$src_path)) {
    return(citation_provided(pkg$src_path))
  }

  citation_auto(pkg)

}

citation_provided <- function(src_path) {
  provided_citation <- read_citation(src_path)

  text_version <- format(provided_citation, style = "textVersion")
  html_version <- if (identical(text_version, "")) {
    format(provided_citation, style = "html")
  } else {
    paste0("<p>", text_version, "</p>")
  }

  cit <- list(
    html = html_version,
    bibtex = format(provided_citation, style = "bibtex")
  )

  return(purrr::transpose(cit))
}

citation_auto <- function(pkg) {
  autocit <- utils::packageDescription(pkg$package)
  autocit$`Date/Publication` <- Sys.time()
  cit <- utils::citation(auto = autocit)
  list(
    html = paste0("<p>", format(cit, style = "textVersion"), "</p>"),
    bibtex = format(cit, style = "bibtex")
  )
}

build_citation_authors <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  source <- if (has_citation(pkg$src_path)) {
    repo_source(pkg, "inst/CITATION")
  } else {
    repo_source(pkg, "DESCRIPTION")
  }

  data <- list(
    pagetitle = tr_("Authors and Citation"),
    citations = data_citations(pkg),
    authors = unname(data_authors(pkg)$all),
    source = source
  )

  data$before <- markdown_text_block(pkg$meta$authors$before, pkg = pkg)
  data$after <- markdown_text_block(pkg$meta$authors$after, pkg = pkg)

  render_page(pkg, "citation-authors", data, "authors.html")
}
