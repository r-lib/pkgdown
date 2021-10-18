
pkgdown_footer <- function(data, pkg) {

  footer_components <- list(
    authors = footer_authors(data, pkg),
    pkgdown = footer_pkgdown(data)
  )

  # footer left
  left_structure <- pkg$meta$footer$left$structure %||% c("authors")

  left_components <- modify_list(
    footer_components,
    pkg$meta$footer$left$components
  )

  check_components(
    needed = left_structure,
    present = names(left_components),
    where = c("footer", "left", "components"),
    pkg = pkg
  )

  left_final_components <- markdown_text_block(
    paste0(left_components[left_structure], collapse = " "),
    pkg = pkg
  )

  # footer right
  right_structure <- pkg$meta$footer$right$structure %||% c("pkgdown")

  right_components <- modify_list(
    footer_components,
    pkg$meta$footer$right$components
  )

  check_components(
    needed = right_structure,
    present = names(right_components),
    where = c("footer", "right", "components"),
    pkg = pkg
  )

  right_final_components <- markdown_text_block(
    paste0(right_components[right_structure], collapse = " "),
    pkg = pkg
  )

  list(left = left_final_components, right = right_final_components)
}

footer_authors <- function(data, pkg) {
  text <- pkg$meta$authors$footer$text %||% "Developed by"
  paste0(trimws(text), " ", data$package$authors, ".")
}

footer_pkgdown <- function(data) {
  paste0(
    'Site built with <a href="https://pkgdown.r-lib.org/">pkgdown</a> ',
    data$pkgdown$version, "."
  )
}
