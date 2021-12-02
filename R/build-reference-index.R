data_reference_index <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  meta <- pkg$meta[["reference"]] %||% default_reference_index(pkg)
  if (length(meta) == 0) {
    return(list())
  }

  rows <- meta %>%
    purrr::imap(data_reference_index_rows, pkg = pkg) %>%
    purrr::compact() %>%
    unlist(recursive = FALSE)

  has_icons <- purrr::some(rows, ~ .x$row_has_icons %||% FALSE)

  check_missing_topics(rows, pkg)

  print_yaml(list(
    pagetitle = tr_("Function reference"),
    rows = rows,
    has_icons = has_icons
  ))
}

data_reference_index_rows <- function(section, index, pkg) {
  if (identical(section$title, "internal")) {
    return(list())
  }

  rows <- list()
  if (has_name(section, "title")) {
    rows[[1]] <- list(
      title = section$title,
      slug = make_slug(section$title),
      desc = markdown_text_block(section$desc, pkg = pkg)
    )
  }

  if (has_name(section, "subtitle")) {
    rows[[2]] <- list(
      subtitle = section$subtitle,
      slug = make_slug(section$subtitle),
      desc = markdown_text_block(section$desc, pkg = pkg)
    )
  }


  if (has_name(section, "contents")) {
    check_all_characters(section$contents, index, pkg)
    contents <- purrr::imap(section$contents, content_info, pkg = pkg, section = index)
    contents <- do.call(rbind, contents)
    contents <- contents[!duplicated(contents$name), , drop = FALSE]

    names <- contents$name
    contents$name <- NULL

    rows[[3]] <- list(
      topics = purrr::transpose(contents),
      names = names,
      row_has_icons = !purrr::every(contents$icon, is.null)
    )
  }

  purrr::compact(rows)
}

check_all_characters <- function(contents, index, pkg) {
  any_not_char <- any(purrr::map_lgl(contents, function(x) {typeof(x) != "character"}))

  if (!any_not_char) {
    return(invisible())
  }

  abort(
    c(
      sprintf(
        "Item %s in section %s in %s must be a character.",
        toString(which(any_not_char)),
        index,
        pkgdown_field(pkg, "reference")
      ),
      i = "You might need to add '' around e.g. - 'N' or - 'off'."
    )
  )

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
    text <- sprintf("Topics missing from index: %s", unname(pkg$topics$name[missing]))
    if (on_ci()) {
      abort(text)
    } else {
      warn(text)
    }
  }
}

on_ci <- function() {
  isTRUE(as.logical(Sys.getenv("CI")))
}
