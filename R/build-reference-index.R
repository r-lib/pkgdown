data_reference_index <- function(pkg = ".", error_call = caller_env()) {
  pkg <- as_pkgdown(pkg)

  meta <- config_pluck_reference(pkg, error_call)
  if (length(meta) == 0) {
    return(list())
  }

  rows <- unwrap_purrr_error(purrr::imap(
    meta,
    data_reference_index_rows,
    pkg = pkg,
    call = error_call
  ))
  rows <- purrr::list_c(rows)

  has_icons <- purrr::some(rows, ~ .x$row_has_icons %||% FALSE)

  check_missing_topics(rows, pkg, error_call = error_call)
  rows <- Filter(function(x) !x$is_internal, rows)

  print_yaml(list(
    pagetitle = tr_("Package index"),
    rows = rows,
    has_icons = has_icons
  ))
}

config_pluck_reference <- function(pkg, call = caller_env()) {
  ref <- config_pluck_list(
    pkg,
    "reference",
    default = default_reference_index(pkg)
  )

  for (i in seq_along(ref)) {
    section <- ref[[i]]
    config_check_list(
      section,
      error_path = paste0("reference[", i, "]"),
      error_pkg = pkg,
      error_call = call
    )
    config_check_string(
      section$title,
      error_path = paste0("reference[", i, "].title"),
      error_pkg = pkg,
      error_call = call
    )
    config_check_string(
      section$subtitle,
      error_path = paste0("reference[", i, "].subtitle"),
      error_pkg = pkg,
      error_call = call
    )
    if (has_name(section, "contents")) {
      check_contents(
        section$contents,
        i,
        pkg,
        prefix = "reference",
        call = call
      )
    }
  }

  ref
}

check_contents <- function(contents, index, pkg, prefix, call = caller_env()) {
  if (length(contents) == 0) {
    config_abort(
      pkg,
      "{.field {prefix}[{index}].contents} is empty.",
      call = call
    )
  }

  is_null <- purrr::map_lgl(contents, is.null)
  if (any(is_null)) {
    j <- which(is_null)[1]
    config_abort(
      pkg,
      "{.field {prefix}[{index}].contents[{j}]} is empty.",
      call = call
    )
  }

  is_char <- purrr::map_lgl(contents, is.character)
  if (!all(is_char)) {
    j <- which(!is_char)[1]
    config_abort(
      pkg,
      c(
        "{.field {prefix}[{index}].contents[{j}]} must be a string.",
        i = "You might need to add '' around special YAML values like 'N' or 'off'"
      ),
      call = call
    )
  }
}


data_reference_index_rows <- function(
  section,
  index,
  pkg,
  call = caller_env()
) {
  is_internal <- identical(section$title, "internal")

  rows <- list()
  if (has_name(section, "title")) {
    rows[[1]] <- list(
      title = markdown_text_inline(
        pkg,
        section$title,
        error_path = paste0("reference[", index, "].title"),
        error_call = call
      ),
      slug = make_slug(section$title),
      desc = markdown_text_block(pkg, section$desc),
      is_internal = is_internal
    )
  }

  if (has_name(section, "subtitle")) {
    rows[[2]] <- list(
      subtitle = markdown_text_inline(
        pkg,
        section$subtitle,
        error_path = paste0("reference[", index, "].subtitle"),
        error_call = call
      ),
      slug = make_slug(section$subtitle),
      desc = markdown_text_block(pkg, section$desc),
      is_internal = is_internal
    )
  }

  if (has_name(section, "contents")) {
    topics <- section_topics(
      pkg,
      section$contents,
      error_path = paste0("reference[", index, "].contents"),
      error_call = call
    )

    names <- topics$name
    topics$name <- NULL

    rows[[3]] <- list(
      topics = purrr::transpose(topics),
      names = names,
      row_has_icons = !purrr::every(topics$icon, is.null),
      is_internal = is_internal
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
      title = tr_("All functions"),
      contents = auto_quote(unname(exported$name))
    )
  ))
}

check_missing_topics <- function(rows, pkg, error_call = caller_env()) {
  # Cross-reference complete list of topics vs. topics found in index page
  all_topics <- purrr::list_c(purrr::map(rows, "names"))
  in_index <- pkg$topics$name %in% all_topics

  missing <- !in_index & !pkg$topics$internal

  if (any(missing)) {
    config_abort(
      pkg,
      c(
        "{sum(missing)} topic{?s} missing from index: {.val {pkg$topics$name[missing]}}.",
        i = paste(
          "Either add to the reference index,",
          "or use {.code @keywords internal} to drop from the index."
        )
      ),
      call = error_call
    )
  }
}
