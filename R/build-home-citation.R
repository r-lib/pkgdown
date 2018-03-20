
has_citation <- function(path = ".") {
  file_exists(path(path, 'inst/CITATION'))
}

create_meta <- function(path) {
  path <- path(path, "DESCRIPTION")

  dcf <- read.dcf(path)
  meta <- as.list(dcf[1, ])

  meta
}

read_citation <- function(path = ".") {
  if (!has_citation(path)) {
    return(character())
  }
  meta <- create_meta(path)
  cit_path <- path(path, 'inst/CITATION')

  utils::readCitationFile(cit_path, meta = meta)
}

data_home_sidebar_citation <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  if (!has_citation(pkg$src_path)) {
    return(character())
  }

  citation <- paste0("<a href='authors.html'>Citing ", pkg$package, "</li>")

  sidebar_section("Citation", citation)
}

data_citations <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)
  cit <- read_citation(pkg$src_path)

  list(
    html = format(cit, style = "html"),
    bibtex = format(cit, style = "bibtex")
  ) %>% purrr::transpose()
}

build_citation_authors <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  data <- list(
    pagetitle = "Citation and Authors",
    citations = data_citations(pkg),
    authors = unname(data_authors(pkg)$all)
  )

  render_page(pkg, "citation-authors", data, "authors.html")
}
