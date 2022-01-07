data_footer <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  meta_footer <- pkg$meta$footer
  components <- modify_list(footnote_components(pkg), meta_footer$components)
  structure <- modify_list(footnote_structure(), meta_footer$structure)

  left <- markdown_text_block(paste0(components[structure$left], collapse = " "))
  right <- markdown_text_block(paste0(components[structure$right], collapse = " "))

  list(left = left, right = right)
}

footnote_components <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  # Authors
  roles <- pkg$meta$authors$footer$roles %||% default_roles()
  authors <- data_authors(pkg, roles = roles)$main %>%
    purrr::map_chr("name") %>%
    paste(collapse = ", ")

  prefix <- pkg$meta$authors$footer$text %||% tr_("Developed by")
  developed_by <- paste0(trimws(prefix), " ", authors, ".")

  # pkgdown
  built_with <- sprintf(
    tr_('Site built with <a href="%s">pkgdown</a> %s.'),
    "https://pkgdown.r-lib.org/",
    utils::packageVersion("pkgdown")
  )

  print_yaml(list(
    developed_by = developed_by,
    built_with = built_with,
    package = pkg[["package"]]
  ))
}

footnote_structure <- function() {
  print_yaml(list(
    left = "developed_by",
    right = "built_with"
  ))
}
