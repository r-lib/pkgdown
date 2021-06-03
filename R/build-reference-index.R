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
    pagetitle = "Function reference",
    rows = rows,
    has_icons = has_icons
  ))
}

data_reference_index_rows <- function(section, index, pkg) {
  rows <- list()
  if (has_name(section, "title")) {
    rows[[1]] <- list(
      title = section$title,
      slug = paste0("section-", make_slug(section$title)),
      desc = markdown_text(section$desc, pkg = pkg)
    )
  }

  if (has_name(section, "subtitle")) {
    rows[[2]] <- list(
      subtitle = section$subtitle,
      slug = paste0("section-", make_slug(section$subtitle)),
      desc = markdown_text(section$desc, pkg = pkg)
    )
  }


  if (has_name(section, "contents")) {
    any_not_char <- any(purrr::map_lgl(section$contents, is_not_character))
    if (any_not_char) {
      abort(
        paste(
          sprintf(
            "Content %s in section %s in %s must be a character.",
            toString(which(any_not_char)),
            index,
            pkgdown_field(pkg, "reference")
          ),
          sprintf(
            "%s You might need to add '' around e.g. - 'N' or - 'off'.",
            crayon::bold("i")
          ),
          sep = "\n"
        )
      )
    }
    contents <- purrr::imap(section$contents, content_info, pkg = pkg, section = index)
    names <- unique(unlist(purrr::map(contents, "name")))
    contents <- purrr::map(contents, function(x) x[names(x) != "name"])
    contents <- do.call(rbind, contents)
    rows[[3]] <- list(
      topics = purrr::transpose(contents),
      names = names,
      row_has_icons = !purrr::every(contents$icon, is.null)
    )
  }

  purrr::compact(rows)
}

is_not_character <- function(x) {
  !(typeof(x) == "character" && nzchar(x))
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
