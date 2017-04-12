data_reference_index <- function(pkg = ".", depth = 1L) {
  pkg <- as_pkgdown(pkg)

  meta <- pkg$meta[["reference"]] %||% default_reference_index(pkg)
  sections <- meta %>%
    purrr::map(data_reference_index_section, pkg = pkg, depth = depth) %>%
    purrr::compact()

  # Cross-reference complete list of topics vs. topics found in index page
  all_topics <- meta %>%
    purrr::map(~ select_topics(.$contents, pkg$topics)) %>%
    purrr::reduce(union)
  in_index <- seq_along(pkg$topics$name) %in% all_topics

  missing <- !in_index & !pkg$topics$internal
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

  # Find topics in this section
  in_section <- select_topics(section$contents, pkg$topics)
  section_topics <- pkg$topics[in_section, ]

  contents <- tibble::tibble(
    path = section_topics$file_out,
    aliases = purrr::map2(section_topics$funs, section_topics$name, ~ .x %||% .y),
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
      contents = paste0('`', pkg$topics$name[!pkg$topics$internal], '`')
    )
  ))
}
