data_footer <- function(pkg = ".", call = caller_env()) {
  pkg <- as_pkgdown(pkg)

  config_pluck_list(pkg, "footer", call = call)
  meta_components <- config_pluck_list(pkg, "footer.components", call = call)
  components <- modify_list(
    footnote_components(pkg, call = call),
    meta_components
  )

  meta_structure <- config_pluck_list(pkg, "footer.structure", call = call)
  structure <- modify_list(footnote_structure(), meta_structure)

  left <- markdown_text_block(
    pkg,
    paste0(components[structure$left], collapse = " ")
  )
  right <- markdown_text_block(
    pkg,
    paste0(components[structure$right], collapse = " ")
  )

  list(left = left, right = right)
}

footnote_components <- function(pkg = ".", call = caller_env()) {
  pkg <- as_pkgdown(pkg)

  # Authors
  roles <- config_pluck_character(
    pkg,
    "authors.footer.roles",
    default = default_roles(),
    call = call
  )
  authors <- data_authors(pkg, roles = roles)$main
  authors_str <- paste(purrr::map_chr(authors, "name"), collapse = ", ")

  prefix <- config_pluck_string(
    pkg,
    "authors.footer.text",
    default = tr_("Developed by"),
    call = call
  )
  developed_by <- paste0(trimws(prefix), " ", authors_str, ".")

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
