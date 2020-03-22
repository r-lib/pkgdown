data_reference_index <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  meta <- pkg$meta[["reference"]] %||% default_reference_index(pkg)
  if (length(meta) == 0) {
    return(list())
  }

  rows <- meta %>%
    purrr::map(data_reference_index_rows, pkg = pkg) %>%
    purrr::compact() %>%
    unlist(recursive = FALSE)

  has_icons <- purrr::some(rows, ~ .x$row_has_icons %||% FALSE)

  check_missing_topics(rows, pkg)

  print_yaml(list(
    pagetitle = "Function reference",
    rows = rows,
    has_icons = has_icons
  ))
}

data_reference_index_rows <- function(section, pkg) {
  rows <- list()
  if (has_name(section, "title")) {
    rows[[1]] <- list(
      title = section$title,
      slug = paste0("section-", make_slug(section$title)),
      desc = markdown_text(section$desc)
    )
  }

  if (has_name(section, "subtitle")) {
    rows[[2]] <- list(
      subtitle = section$subtitle,
      slug = paste0("section-", make_slug(section$subtitle)),
      desc = markdown_text(section$desc)
    )
  }


  if (has_name(section, "contents")) {
    in_section <- select_topics(section$contents, pkg$topics)
    topics <- pkg$topics[in_section, ]

    contents <- tibble::tibble(
      path = topics$file_out,
      aliases = purrr::map2(
        topics$funs,
        topics$name,
        ~ if (length(.x) > 0) .x else .y
      ),
      title = topics$title,
      icon = find_icons(topics$alias, path(pkg$src_path, "icons"))
    )

    rows[[3]] <- list(
      topics = purrr::transpose(contents),
      names = topics$name,
      row_has_icons = !purrr::every(contents$icon, is.null)
    )
  }

  purrr::compact(rows)
}


find_icons <- function(x, path) {
  purrr::map(x, find_icon, path = path)
}
find_icon <- function(aliases, path) {
  names <- paste0(aliases, ".png")
  exists <- file_exists(path(path, names))

  if (!any(exists)) {
    NULL
  } else {
    names[which(exists)[1]]
  }
}

default_reference_index <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  exported <- pkg$topics[!pkg$topics$internal, , drop = FALSE]
  if (nrow(exported) == 0) {
    return(list())
  }

  print_yaml(list(
    list(
      title = "All functions",
      contents = paste0('`', exported$name, '`')
    )
  ))
}

check_missing_topics <- function(rows, pkg) {
  # Cross-reference complete list of topics vs. topics found in index page
  all_topics <- rows %>% purrr::map("names") %>% unlist(use.names = FALSE)
  in_index <- pkg$topics$name %in% all_topics

  missing <- !in_index & !pkg$topics$internal
  if (any(missing)) {
    warn(c("Topics missing from index: ", unname(pkg$topics$name[missing])))
  }
}
