has_class <- function(html, class) {
  classes <- strsplit(xml2::xml_attr(html, "class"), " ")
  purrr::map_lgl(classes, ~ any(class %in% .x))
}

tweak_class_prepend <- function(x, class) {
  if (length(x) == 0) {
    return(invisible())
  }

  cur <- xml2::xml_attr(x, "class")
  xml2::xml_attr(x, "class") <- ifelse(is.na(cur), class, paste(class, cur))
  invisible()
}
