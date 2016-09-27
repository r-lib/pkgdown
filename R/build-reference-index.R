build_reference_index <- function(pkg = ".", path = NULL, depth = 1L) {
  render_page(
    pkg, "reference-index",
    data = data_reference_index(pkg),
    path = out_path(path, "index.html"),
    depth = depth
  )
}

data_reference_index <- function(pkg = ".") {
  pkg <- as_staticdocs(pkg)

  meta <- meta_reference_index(pkg)
  sections <- compact(lapply(meta, data_reference_index_section, pkg = pkg))

  # Cross-reference complete list of topics vs. topics found in index page
  in_index <- meta %>%
    purrr::map(~ has_topic(pkg$topics$alias, .$contents)) %>%
    purrr::reduce(`+`)

  missing <- (in_index == 0) & !pkg$topics$internal
  if (any(missing)) {
    warning(
      "Topics missing from index: ",
      paste(pkg$topics$name[missing], collapse = ", "),
      call. =  FALSE,
      immediate. = TRUE
    )
  }

  list(
    pagetitle = "Function reference",
    version = pkg$version,
    sections = sections
  )
}

data_reference_index_section <- function(section, pkg) {
  if (!set_contains(names(section), c("title", "contents"))) {
    warning(
      "Section must have components `title`, `contents`",
      call. = FALSE,
      immediate. = TRUE
    )
    return(NULL)
  }

  # Match topics against any aliases
  in_section <- has_topic(pkg$topics$alias, section$contents)
  section_topics <- pkg$topics[in_section, ]
  contents <-
    tibble::tibble(
      path = section_topics$file_out,
      aliases = section_topics$alias,
      title = section_topics$title
    ) %>%
    purrr::transpose()

  list(
    title = section$title,
    desc = section$desc,
    class = section$class,
    contents = contents
  )
}

meta_reference_index <- function(pkg = ".") {
  pkg <- as_staticdocs(pkg)

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

# Character vector of contents: xyz, starts_with("xyz")
# List of aliases
has_topic <- function(topics, matches) {
  matchers <- purrr::map(matches, topic_matcher)
  topics %>%
    purrr::map_lgl(~ purrr::some(matchers, function(f) any(f(.))))
}

# Takes text specification and converts it to a predicate function
topic_matcher <- function(text) {
  stopifnot(is.character(text), length(text) == 1)
  expr <- parse(text = text)[[1]]

  if (is.name(expr) || is.character(expr)) {
    function(topics) topics %in% as.character(expr)
  } else {
    topic_helpers <- list(
      starts_with = function(x) {
        function(topics) grepl(paste0("^", x), topics)
      },
      ends_width = function(x) {
        function(topics) grepl(paste0(x, "$"), topics)
      },
      matches = function(x) {
        function(topics) grepl(x, topics)
      }
    )
    eval(expr, topic_helpers)
  }
}

