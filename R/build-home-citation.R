
has_citation <- function(path = ".") {
  file_exists(path(path, 'inst/CITATION'))
}

need_citation <- function(pkg) {
  has_citation(pkg$src_path) || identical(pkg$meta$forcecitation, TRUE)
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

  if (!need_citation(pkg)) {
    return(character())
  }

  citation <- paste0("<a href='authors.html'>Citing ", pkg$package, "</li>")

  sidebar_section("Citation", citation)
}

data_citations <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  if (has_citation(pkg$src_path)) {

    cit <- read_citation(pkg$src_path)

    text_version <- format(cit, style = "textVersion")
    if (identical(text_version, "")) {
      cit <- list(
        html = format(cit, style = "html"),
        bibtex = format(cit, style = "bibtex")
      )
    } else {
      cit <- list(
        html = paste0("<p>",text_version, "</p>"),
        bibtex = format(cit, style = "bibtex")
      )
    }

    return(purrr::transpose(cit))
  }

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
  data <- list(
    pagetitle = "Citation and Authors",
    citations = data_citations(pkg),
    authors = unname(data_authors(pkg)$all),
    source = source
  )

  if(has_citation(pkg$src_path)) {
    data$source <- repo_source(pkg, "inst/CITATION")
  } else {
    data$source <- repo_source(pkg, "DESCRIPTION")
  }


  render_page(pkg, "citation-authors", data, "authors.html")
}
