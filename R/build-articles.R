#' Build articles
#'
#' Each Rmarkdown vignette in \code{vignettes/} and its subdirectories is
#' rendered. Vignettes are rendered using a special document format that
#' reconciles \code{\link[rmarkdown]{html_document}()} with your pkgdown
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
#' pkgdown will check that all vignettes are included in the index
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
  pkg <- as_pkgdown(pkg)
  if (!has_vignettes(pkg$path)) {
    return(invisible())
  }

  rule("Building articles")
  mkdir(path)

  render_article <- function(file_in, file_out, vig_depth, ...) {
    format <- build_rmarkdown_format(pkg, depth = vig_depth + depth)
    on.exit(unlink(format$path), add = TRUE)

    message("Building vignette '", file_in, "'")
    path <- rmarkdown::render(
      file.path(pkg$path, "vignettes", file_in),
      output_format = format$format,
      output_file = basename(file_out),
      output_dir = file.path(path, dirname(file_out)),
      quiet = TRUE,
      envir = new.env(parent = globalenv())
    )
    tweak_rmarkdown_html(path, depth = vig_depth + depth, index = pkg$topics)
  }
  purrr::pwalk(pkg$vignettes, render_article)

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
      toc_depth = 2,
      self_contained = FALSE,
      theme = NULL,
      template = path
    )
  )
}

tweak_rmarkdown_html <- function(path, depth = 1L, index = NULL) {
  html <- xml2::read_html(path, encoding = "UTF-8")

  # Automatically link funtion mentions
  autolink_html(html, depth = depth, index = index)

  # Tweak classes of navbar
  toc <- xml2::xml_find_all(html, ".//div[@id='tocnav']//ul")
  xml2::xml_attr(toc, "class") <- "nav nav-pills nav-stacked"

  xml2::write_html(html, path, format = FALSE)

  path
}



# Articles index ----------------------------------------------------------

build_articles_index <- function(pkg = ".", path = NULL, depth = 1L) {
  render_page(
    pkg,
    "vignette-index",
    data = data_articles_index(pkg, depth = depth),
    path = out_path(path, "index.html"),
    depth = depth
  )
}

data_articles_index <- function(pkg = ".", depth = 1L) {
  pkg <- as_pkgdown(pkg)

  meta <- pkg$meta$articles %||% default_articles_index(pkg)
  sections <- meta %>%
    purrr::map(data_articles_index_section, pkg = pkg, depth = depth) %>%
    purrr::compact()

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

data_articles_index_section <- function(section, pkg, depth = 1L) {
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
    desc = markdown_text(section$desc, depth = depth, index = pkg$topics),
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
  pkg <- as_pkgdown(pkg)

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
