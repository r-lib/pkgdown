#' Build articles
#'
#' Each Rmarkdown vignette in \code{vignettes/} and its subdirectories is
#' rendered. Vignettes are rendered using a special document format that
#' reconciles \code{\link[rmarkdown]{html_document}()} with your staticdocs
#' template.
#'
#' @section YAML config:
#' To tweak the index page, you need a section called \code{articles},
#' which provides a list of sections containing, a \code{title}, list of
#' \code{contents}, and optional \code{description}.
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
#' Note that \code{contents} can contain either a list of vignette names
#' (including subdirectories), or if the functions in a section share a
#' common prefix or suffix, you can use \code{starts_with("prefix")} and
#' \code{ends_with("suffix")} to select them all. For more complex naming
#' schemes you can use an aribrary regular expression with
#' \code{matches("regexp")}.
#'
#' staticdocs will check that all vignettes are included in the index
#' this page, and will generate a warning if you have missed any.
#'
#' @section Supressing vignettes:
#'
#' If you want articles that are not vignettes, either put them in
#' subdirectories or list in \code{.Rbuildignore}. An articles link
#' will be automatically added to the default navbar if the vignettes
#' directory is present: if you do not want this, you will need to
#' customise the navbar. See \code{\link{build_site}} details.
#'
#' @param pkg Path to source package.
#' @param path Output path.
#' @param depth Depth of path relative to root of documentation.
#'   Used to adjust relative links in the navbar.
#' @export
build_articles <- function(pkg = ".", path = "docs/articles", depth = 1L) {
  pkg <- as_staticdocs(pkg)
  if (!has_vignettes(pkg$path)) {
    return(invisible())
  }

  rule("Building articles")
  mkdir(path)

  format <- build_rmarkdown_format(pkg, depth = depth)
  on.exit(unlink(format$path), add = TRUE)

  render_article <- function(file_in, file_out) {
    message("Building vignette '", file_in, "'")
    rmarkdown::render(
      file.path("vignettes", file_in),
      output_format = format$format,
      output_file = file.path(path, file_out),
      output_dir = path,
      quiet = TRUE,
      envir = new.env(parent = globalenv())
    )
  }
  purrr::walk2(pkg$vignettes$file_in, pkg$vignettes$file_out, render_article)

  build_articles_index(pkg, path = path, depth = depth)

  invisible()
}

build_rmarkdown_format <- function(pkg = ".", depth = 1L) {
  # Render vignette template to temporary file
  path <- tempfile(fileext = ".html")
  data <- list(
    pagetitle = "$title$"
  )
  suppressMessages(
    render_page(pkg, "vignette", data, path, depth = depth)
  )

  list(
    path = path,
    format = rmarkdown::html_document(
      toc = TRUE,
      self_contained = FALSE,
      theme = NULL,
      template = path
    )
  )
}

# Articles index ----------------------------------------------------------

build_articles_index <- function(pkg = ".", path = NULL, depth = 1L) {
  render_page(
    pkg,
    "vignette-index",
    data = data_articles_index(pkg),
    path = out_path(path, "index.html"),
    depth = depth
  )
}

data_articles_index <- function(pkg = ".") {
  pkg <- as_staticdocs(pkg)

  meta <- pkg$meta$articles %||% default_articles_index()
  sections <- purrr::compact(lapply(meta, data_articles_index_section, pkg = pkg))

  # Check for unlisted vignettes
  listed <- meta %>%
    purrr::map("contents") %>%
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
  in_section <- has_vignette(pkg$vignettes$name, section$contents)
  section_vignettes <- pkg$vignettes[in_section, ]
  contents <- tibble::tibble(
    path = section_vignettes$file_out,
    title = section_vignettes$title
  )

  list(
    title = section$title,
    desc = section$desc,
    class = section$class,
    contents = purrr::transpose(contents)
  )
}

has_vignette <- function(vignettes, matches) {
  matchers <- purrr::map(matches, topic_matcher)

  matchers %>%
    purrr::map(~ .x(vignettes)) %>%
    purrr::reduce(`|`)
}

default_articles_index <- function(pkg = ".") {
  pkg <- as_staticdocs(pkg)

  print_yaml(list(
    list(
      title = "All vignettes",
      desc = NULL,
      contents = pkg$vignettes$name
    )
  ))
}

has_vignettes <- function(path = ".") {
  file.exists(file.path(path, "vignettes"))
}
