#' Build articles
#'
#' Each Rmarkdown vignette in `vignettes/` and its subdirectories is
#' rendered. Vignettes are rendered using a special document format that
#' reconciles [rmarkdown::html_document()] with your pkgdown
#' template.
#'
#' @section YAML config:
#' To tweak the index page, you need a section called `articles`,
#' which provides a list of sections containing, a `title`, list of
#' `contents`, and optional `description`.
#'
#' For example, this imaginary file describes some of the structure of
#' the \href{http://rmarkdown.rstudio.com/articles.html}{R markdown articles}:
#'
#' \preformatted{
#' articles:
#' - title: R Markdown
#'   contents:
#'   - starts_with("authoring")
#' - title: Websites
#'   contents:
#'   - rmarkdown_websites
#'   - rmarkdown_site_generators
#' }
#'
#' Note that `contents` can contain either a list of vignette names
#' (including subdirectories), or if the functions in a section share a
#' common prefix or suffix, you can use `starts_with("prefix")` and
#' `ends_with("suffix")` to select them all. If you don't care about
#' position within the string, use `contains("word")`. For more complex
#' naming schemes you can use an aribrary regular expression with
#' `matches("regexp")`.
#'
#' pkgdown will check that all vignettes are included in the index
#' this page, and will generate a warning if you have missed any.
#'
#' @section Supressing vignettes:
#'
#' If you want articles that are not vignettes, either put them in
#' subdirectories or list in `.Rbuildignore`. An articles link
#' will be automatically added to the default navbar if the vignettes
#' directory is present: if you do not want this, you will need to
#' customise the navbar. See [build_site()] details.
#'
#' @param pkg Path to source package. If R working directory is not
#'     set to the source directory, then pkg must be a fully qualified
#'     path to the source directory (not a relative path).
#' @param quiet Set to `FALSE` to display output of knitr and
#'   pandoc. This is useful when debugging.
#' @param preview If `TRUE`, or `is.na(preview) && interactive()`, will preview
#'   freshly generated section in browser.
#' @export
build_articles <- function(pkg = ".",
                           quiet = TRUE,
                           preview = NA) {
  pkg <- section_init(pkg, depth = 1L)

  if (nrow(pkg$vignettes) == 0L) {
    return(invisible())
  }

  rule("Building articles")

  build_articles_index(pkg)
  purrr::walk(pkg$vignettes$name, render_article, pkg = pkg, quiet = quiet)

  section_fin(pkg, "articles", preview = preview)
}

render_article <- function(pkg = ".",
                           name,
                           data = list(),
                           quiet = TRUE) {
  pkg <- as_pkgdown(pkg)

  if (name %in% c("index.Rmd", "README.Rmd")) {
    depth <- 0L
    output_file <- "index.html"
    input <- name
    strip_header <- TRUE
    toc <- FALSE
  } else {
    depth <- dir_depth(name) + 1L
    vig <- match(name, pkg$vignettes$name)
    if (is.na(vig)) {
      stop("Can't find article called '", name, "'", call. = FALSE)
    }
    output_file <- pkg$vignettes$file_out[vig]
    input <- pkg$vignettes$file_in[vig]
    toc <- TRUE
    strip_header <- FALSE
  }

  cat_line("Building article '", output_file, "'")

  scoped_package_context(pkg$package, pkg$topic_index, pkg$article_index)
  scoped_file_context(depth = depth)

  default_data <- list(
    pagetitle = "$title$",
    opengraph = list(description = "$description$")
  )
  data <- utils::modifyList(default_data, data)

  format <- build_rmarkdown_format(pkg, depth = depth, data = data, toc = toc)

  path <- render_rmarkdown(
    input = path_abs(input, pkg$src_path),
    output_format = format,
    output_file = path_file(output_file),
    output_dir = path(pkg$dst_path, path_dir(output_file)),
    intermediates_dir = tempdir(),
    quiet = quiet
  )

  update_rmarkdown_html(path, strip_header = strip_header)
}

# Generates RMarkdown format by rendering inst/template/context-vignette.html
# This template contains pandoc template tags so creates a file that we can
# use as an RMarkdown/pandoc template.
build_rmarkdown_format <- function(pkg = ".",
                                   depth = 1L,
                                   data = list(),
                                   toc = TRUE) {
  path <- tempfile(fileext = ".html")
  render_page(pkg, "vignette", data, path, depth = depth, quiet = TRUE)

  out <- rmarkdown::html_document(
    toc = toc,
    toc_depth = 2,
    self_contained = FALSE,
    theme = NULL,
    template = path
  )

  # Remove template file when format object is GC'd
  e <- env()
  reg.finalizer(e, function(e) file_delete(path))
  attr(out, "cleanup") <- e

  out
}

update_rmarkdown_html <- function(path, strip_header = FALSE) {
  html <- xml2::read_html(path, encoding = "UTF-8")
  tweak_rmarkdown_html(html, strip_header = strip_header)

  xml2::write_html(html, path, format = FALSE)
  path
}

# Articles index ----------------------------------------------------------

build_articles_index <- function(pkg = ".") {
  dir_create(path(pkg$dst_path, "articles"))
  render_page(
    pkg,
    "vignette-index",
    data = data_articles_index(pkg),
    path = path("articles", "index.html")
  )
}

data_articles_index <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  meta <- pkg$meta$articles %||% default_articles_index(pkg)
  sections <- meta %>%
    purrr::map(data_articles_index_section, pkg = pkg) %>%
    purrr::compact()

  # Check for unlisted vignettes
  listed <- sections %>%
    purrr::map("contents") %>%
    purrr::map(. %>% purrr::map_chr("name")) %>%
    purrr::flatten_chr() %>%
    unique()
  missing <- !(pkg$vignettes$name %in% listed)

  if (any(missing)) {
    warning(
      "Vignettes missing from index: ",
      paste(pkg$vignettes$name[missing], collapse = ", "),
      call. =  FALSE,
      immediate. = TRUE
    )
  }

  print_yaml(list(
    pagetitle = "Articles",
    sections = sections
  ))
}

data_articles_index_section <- function(section, pkg) {
  if (!set_contains(names(section), c("title", "contents"))) {
    warning(
      "Section must have components `title`, `contents`",
      call. = FALSE,
      immediate. = TRUE
    )
    return(NULL)
  }

  # Match topics against any aliases
  in_section <- select_vignettes(section$contents, pkg$vignettes)
  section_vignettes <- pkg$vignettes[in_section, ]
  contents <- tibble::tibble(
    name = section_vignettes$name,
    path = path_rel(section_vignettes$file_out, "articles"),
    title = section_vignettes$title
  )

  list(
    title = section$title,
    desc = markdown_text(section$desc),
    class = section$class,
    contents = purrr::transpose(contents)
  )
}

# Quick hack: create the same structure as for topics so we can use
# the existing select_topics()
select_vignettes <- function(match_strings, vignettes) {
  topics <- tibble::tibble(
    name = vignettes$name,
    alias = as.list(vignettes$name),
    internal = FALSE
  )
  select_topics(match_strings, topics)
}

default_articles_index <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  print_yaml(list(
    list(
      title = "All vignettes",
      desc = NULL,
      contents = paste0("`", pkg$vignettes$name, "`")
    )
  ))

}
