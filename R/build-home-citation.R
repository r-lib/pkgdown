
has_citation <- function(path = ".") {
  file.exists(file.path(path, 'inst/CITATION'))
}

read_citation <- function(path = ".", encoding) {
  if (!has_citation(path)) {
    return(character())
  }
  path <- file.path(path, 'inst/CITATION')

  utils::readCitationFile(
    path, meta = list(Encoding = encoding)
  )
}

data_home_sidebar_citation <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  if (!has_citation(pkg$path)) {
    return(character())
  }

  name <- pkg$desc$get("Package")[[1]]
  citation <- paste0("<a href='authors.html'>Citing ", name, "</li>")

  list_with_heading(citation, "Citation")
}

data_citations <- function(pkg = ".", encoding = "UTF-8") {
  pkg <- as_pkgdown(pkg)
  cit <- read_citation(pkg$path, encoding)

  list(
    html = format(cit, style = "html"),
    bibtex = format(cit, style = "bibtex")
  ) %>% purrr::transpose()
}

build_citation_authors <- function(pkg = ".",
                                   path = "docs",
                                   encoding = "UTF-8",
                                   depth = 0L) {
  pkg <- as_pkgdown(pkg)

  data <- list(
    pagetitle = "Citation and Authors",
    citations = data_citations(pkg, encoding),
    authors = data_authors(pkg)$all
  )

  render_page(pkg, "citation-authors", data, file.path(path, "authors.html"), depth = depth)
}
