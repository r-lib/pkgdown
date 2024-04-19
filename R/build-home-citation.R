
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

  if (!is.null(meta$Title)) meta$Title <- str_squish(meta$Title)

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
    heading = tr_("Citation"),
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
  cit <- list(
    html = ifelse(
      text_version == "",
      format(provided_citation, style = "html"),
      paste0("<p>", escape_html(text_version), "</p>")
    ),
    bibtex = format(provided_citation, style = "bibtex")
  )

  purrr::transpose(cit)
}

citation_auto <- function(pkg) {
  cit_info <- utils::packageDescription(
    path_file(pkg$src_path),
    lib.loc = path_dir(pkg$src_path)
  )
  cit_info$`Date/Publication` <- cit_info$`Date/Publication` %||% Sys.time()
  if (!is.null(cit_info$Title)) cit_info$Title <- str_squish(cit_info$Title)

  cit <- utils::citation(auto = cit_info)
  list(
    html = format(cit, style = "html"),
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
    citationtitle = tr_("Citation"),
    citations = data_citations(pkg),
    authors = unname(data_authors(pkg)$all),
    source = source
  )

  data$before <- markdown_text_block(pkg$meta$authors$before)
  data$after <- markdown_text_block(pkg$meta$authors$after)

  render_page(pkg, "citation-authors", data, "authors.html")
}
