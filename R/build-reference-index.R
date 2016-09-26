build_reference_index <- function(pkg = ".", path = NULL) {
  data <- data_reference_index(pkg)
  render_page(pkg, "reference-index", data, out_path(path, "index.html"))
}

data_reference_index <- function(pkg = ".") {
  pkg <- as.sd_package(pkg)

  meta <- meta_reference_index(pkg)
  sections <- compact(lapply(meta, data_reference_index_section, pkg = pkg))

  # Cross-reference complete list of topics vs. topics found in index page
  in_index <- meta %>%
    purrr::map(~ topic_has_alias(pkg$topics, .$contents)) %>%
    purrr::reduce(`+`)

  missing <- !in_index && !pkg$topics$internal
  if (any(missing)) {
    warning(
      "Topics missing from index: ",
      paste(pkg$topics$name[missing], collapse = ", "),
      call. =  FALSE
    )
  }

  list(
    pagetitle = "Function reference",
    version = pkg$version,
    sections = sections
  )
}

data_reference_index_section <- function(section, pkg) {
  if (!set_contains(names(section), c("title", "desc", "contents"))) {
    warning(
      "Section must have components `title`, `desc` and `contents`",
      call. = FALSE,
      immediate. = TRUE
    )
    return(NULL)
  }

  # Match topics against any aliases
  in_section <- topic_has_alias(pkg$topics, section$contents)

  contents <- pkg$topics %>%
    dplyr::filter(in_section) %>%
    dplyr::select(path = file_out, aliases = alias, title) %>%
    purrr::transpose()

  list(
    title = section$title,
    desc = section$desc,
    class = section$class,
    contents = contents
  )
}

meta_reference_index <- function(pkg = ".") {
  pkg <- as.sd_package(pkg)

  if (!is.null(pkg$meta$reference)) {
    return(pkg$meta$reference)
  }

  list(
    list(
      title = "All functions",
      desc = NULL,
      contents = pkg$topics$name
    )
  )
}

topic_has_alias <- function(topics, alias) {
  purrr::map_lgl(topics$alias, ~ any(. %in% alias))
}
