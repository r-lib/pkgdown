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
#' @param path Output path. Relative paths are taken relative to the
#'     `pkg` directory.
#' @param depth Depth of path relative to root of documentation.  Used
#'     to adjust relative links in the navbar.
#' @param encoding The encoding of the input files.
#' @param quiet Set to `FALSE` to display output of knitr and
#'   pandoc. This is useful when debugging.
#' @export
build_articles <- function(pkg = ".", path = "docs/articles", depth = 1L,
                           encoding = "UTF-8", quiet = TRUE) {
  old <- set_pkgdown_env("true")
  on.exit(set_pkgdown_env(old))

  pkg <- as_pkgdown(pkg)
  path <- rel_path(path, pkg$path)
  if (!has_vignettes(pkg$path)) {
    return(invisible())
  }

  rule("Building articles")
  mkdir(path)

  # copy everything from vignettes/ to docs/articles
  copy_dir(
    file.path(pkg$path, "vignettes"), path,
    exclude_matching = "rsconnect"
  )

  # Render each Rmd then delete them
  articles <- tibble::tibble(
    input = file.path(path, pkg$vignettes$file_in),
    output_file = pkg$vignettes$file_out,
    depth = pkg$vignettes$vig_depth + depth
  )
  data <- list(pagetitle = "$title$")
  purrr::pwalk(articles, render_rmd,
    pkg = pkg,
    data = data,
    encoding = encoding,
    quiet = quiet
  )
  purrr::walk(articles$input, unlink)

  build_articles_index(pkg, path = path, depth = depth)

  invisible()
}

render_rmd <- function(pkg,
                       input,
                       output_file,
                       strip_header = FALSE,
                       data = list(),
                       toc = TRUE,
                       depth = 1L,
                       encoding = "UTF-8",
                       quiet = TRUE) {

  message("Building article '", output_file, "'")
  scoped_package_context(pkg$package, pkg$topic_index, pkg$article_index)
  scoped_file_context(depth = depth)

  format <- build_rmarkdown_format(pkg, depth = depth, data = data, toc = toc)
  on.exit(unlink(format$path), add = TRUE)

  path <- callr::r_safe(
    function(...) rmarkdown::render(...),
    args = list(
      input,
      output_format = format$format,
      output_file = basename(output_file),
      quiet = quiet,
      encoding = encoding,
      envir = globalenv()
    ),
    show = !quiet
  )
  update_rmarkdown_html(path, strip_header = strip_header, depth = depth)
}

build_rmarkdown_format <- function(pkg = ".",
                                   depth = 1L,
                                   data = list(),
                                   toc = TRUE) {
  # Render vignette template to temporary file
  path <- tempfile(fileext = ".html")
  suppressMessages(
    render_page(pkg, "vignette", data, path, depth = depth)
  )

  list(
    path = path,
    format = rmarkdown::html_document(
      toc = toc,
      toc_depth = 2,
      self_contained = FALSE,
      theme = NULL,
      template = path
    )
  )
}

update_rmarkdown_html <- function(path, strip_header = FALSE, depth = 1L) {
  html <- xml2::read_html(path, encoding = "UTF-8")
  tweak_rmarkdown_html(html, strip_header = strip_header, depth = depth)

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
  in_section <- select_vignettes(section$contents, pkg$vignettes)
  section_vignettes <- pkg$vignettes[in_section, ]
  contents <- tibble::tibble(
    name = section_vignettes$name,
    path = section_vignettes$file_out,
    title = section_vignettes$title
  )

  list(
    title = section$title,
    desc = markdown_text(section$desc, depth = depth),
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

has_vignettes <- function(path = ".") {
  vign_path <- file.path(path, "vignettes")
  file.exists(vign_path) && length(list.files(vign_path))
}
