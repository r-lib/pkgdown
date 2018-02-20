
has_citation <- function(path = ".") {
  file.exists(file.path(path, 'inst/CITATION'))
}

read_citation <- function(path = ".") {
  if (!has_citation(path)) {
    return(character())
  }
  path <- file.path(path, 'inst/CITATION')
  utils::readCitationFile(path)
}

data_home_sidebar_citation <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  if (!has_citation(pkg$path)) {
    return(character())
  }

  name <- pkg$desc$get("Package")[[1]]
  citation <- paste0("<a href='authors.html'>Citing ", name, "</li>")

  paste0(
    '<div id="sidebar_citation">\n',
    list_with_heading(citation, "Citation"),
    '\n</div>'
  )
}

data_citations <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)
  cit <- read_citation(pkg$path)

  list(
    html = format(cit, style = "html"),
    bibtex = format(cit, style = "bibtex")
  ) %>% purrr::transpose()
}

build_citation_authors <- function(pkg = ".", path = "docs", depth = 0L) {
  pkg <- as_pkgdown(pkg)

  data <- list(
    pagetitle = "Citation and Authors",
    citations = data_citations(pkg),
    authors = data_authors(pkg)$all
  )

  render_page(pkg, "citation-authors", data, file.path(path, "authors.html"), depth = depth)
}
