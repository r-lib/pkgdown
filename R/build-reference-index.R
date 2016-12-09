data_reference_index <- function(pkg = ".", depth = 1L) {
  pkg <- as_pkgdown(pkg)

  meta <- pkg$meta[["reference"]] %||% default_reference_index(pkg)
  sections <- meta %>%
    purrr::map(data_reference_index_section, pkg = pkg, depth = depth) %>%
    purrr::compact()

  # Cross-reference complete list of topics vs. topics found in index page
  in_index <- meta %>%
    purrr::map(~ has_topic(pkg$topics$alias, .$contents, .$exclude)) %>%
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

  print_yaml(list(
    pagetitle = "Function reference",
    sections = sections
  ))
}

data_reference_index_section <- function(section, pkg, depth = 1L) {
  if (!set_contains(names(section), c("title", "contents"))) {
    warning(
      "Section must have components `title`, `contents`",
      call. = FALSE,
      immediate. = TRUE
    )
    return(NULL)
  }

  # Match topics against any aliases
  in_section <- has_topic(pkg$topics$alias, section$contents, section$exclude)
  section_topics <- pkg$topics[in_section, ]
  contents <- tibble::tibble(
    path = section_topics$file_out,
    aliases = section_topics$alias,
    title = section_topics$title,
    icon = find_icons(section_topics$alias, file.path(pkg$path, "icons"))
  )
  list(
    title = section$title,
    slug = paste0("section-", make_slug(section$title)),
    desc = markdown_text(section$desc, index = pkg$topics, depth = depth),
    class = section$class,
    contents = purrr::transpose(contents)
  )
}


find_icons <- function(x, path) {
  purrr::map(x, find_icon, path = path)
}
find_icon <- function(aliases, path) {
  names <- paste0(aliases, ".png")
  exists <- file.exists(file.path(path, names))

  if (!any(exists)) {
    NULL
  } else {
    names[which(exists)[1]]
  }
}

default_reference_index <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  print_yaml(list(
    list(
      title = "All functions",
      desc = NULL,
      contents = pkg$topics$name[!pkg$topics$internal]
    )
  ))
}

# Character vector of contents: xyz, starts_with("xyz")
# List of aliases
has_topic <- function(topics, contains, exclude = NULL) {
  match_topic(topics, contains %||% list()) &
    !match_topic(topics, exclude %||% list())
}

match_topic <- function(topics, matches) {
  matchers <- purrr::map(matches, topic_matcher)
  topics %>%
    purrr::map_lgl(~ purrr::some(matchers, function(f) any(f(.))))
}

# Takes text specification and converts it to a predicate function
topic_matcher <- function(text) {
  stopifnot(is.character(text), length(text) == 1)

  if (!grepl("(", text, fixed = TRUE)) {
    function(topics) topics %in% text
  } else {
    expr <- parse(text = text)[[1]]

    topic_helpers <- list(
      starts_with = function(x) {
        function(topics) grepl(paste0("^", x), topics)
      },
      ends_with = function(x) {
        function(topics) grepl(paste0(x, "$"), topics)
      },
      matches = function(x) {
        function(topics) grepl(x, topics)
      }
    )
    eval(expr, topic_helpers)
  }
}

