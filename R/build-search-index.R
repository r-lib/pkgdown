#' Build search index
#'
#' By default pkgdown will create a site search index compiled from Rd file
#' descriptions and vignette content.
#'
#' Data for the index is saved in JSON format in `site-index.json`.
#'
#' @inheritParams build_articles
#' @param index_rd include Rd files in search index
#' @param index_vignette include vignettes in search index
#' @param vignette_path path to rendered vignettes
#'
#' @importFrom jsonlite write_json
#'
#' @export
build_search_index <- function(pkg = ".",
                               path = "docs",
                               depth = 0L,
                               index_rd = TRUE,
                               index_vignette = TRUE,
                               vignette_path = "docs/articles") {
  pkg <- as_pkgdown(pkg)

  rule("Building search index")
  path <- rel_path(path, pkg$path)

  render_page(pkg,
    "search",
    list(pagetitle = "Search results"),
    out_path(path, "search.html"),
    depth = depth)

  message("Collating data for search index")
  data_search <- rbind(
    build_search_home(pkg),
    build_search_rd(pkg, index_rd),
    build_search_vignette(pkg, index_vignette, vignette_path)
  )

  search_index <- create_search_index(data_search)

  message("Writing JSON index")
  search_path <- file.path(path, "site-index.json")
  jsonlite::write_json(search_index, search_path, auto_unbox = TRUE)
}

create_search_index <- function(data_search) {
  # extract words and remove stop words
  data_search$desc <- as.character(data_search$desc)

  list(
    title = data_search$title,
    type = data_search$type,
    href = data_search$href,
    words = purrr::map(data_search$desc, extract_words)
  ) %>% purrr::transpose()
}

#' @importFrom hunspell hunspell_parse
extract_words <- function(words) {
  hunspell::hunspell_parse(words, format = "html")[[1]]
}

build_search_rd <- function(pkg = ".", index_rd = TRUE) {
  pkg <- as_pkgdown(pkg)
  if (!index_rd) return(tibble::tibble())

  scoped_package_context(pkg$package, pkg$topic_index, pkg$article_index)

  topics <- pkg$topics %>% purrr::transpose()

  tibble::tibble(
    title = pkg$topics$name,
    type = "rd",
    desc = purrr::map(topics, data_search_rd),
    href = file.path("reference", pkg$topics$file_out)
  )
}

data_search_rd <- function(topic) {
  scoped_file_context(rdname = gsub("\\.Rd$", "", topic$file_in), depth = 1L)

  tag_names <- purrr::map_chr(topic$rd, ~ class(.)[[1]])
  tags <- split(topic$rd, tag_names)

  paste(as_data(tags$tag_description[[1]])$contents, collapse = "")
}

build_search_vignette <- function(pkg = ".",
                                  index_vignette = TRUE,
                                  vignette_path = "docs/articles") {
  pkg <- as_pkgdown(pkg)
  if (!index_vignette) return(tibble::tibble())

  scoped_package_context(pkg$package, pkg$topic_index, pkg$article_index)

  vig <- pkg$vignettes
  vig_paths <- file.path(vignette_path, vig$file_out)

  tibble::tibble(
    title = pkg$vignettes$name,
    type = "vignette",
    desc = purrr::map(vig_paths, data_search_text),
    href = file.path("articles", pkg$vignettes$file_out)
  )
}

data_search_text <- function(x) {
  paste(readLines(x), collapse = "")
}

build_search_home <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  tibble::tibble(
    title = "README",
    type = "Home page",
    desc = data_search_text("docs/index.html"),
    href = "index.html"
  )
}
