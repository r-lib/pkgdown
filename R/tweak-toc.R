
trim_toc <- function(html) {
  if (count_heading(html) <= 0) {
    xml2::xml_remove(xml2::xml_find_first(html, '//nav[@id="toc"]'))
  }
}

count_heading <- function(html) {
  # - 1 to remove one for the contents header :-)
  sum(purrr::map_dbl(2:6, count_heading_level, html)) - 1
}

count_heading_level <- function(level, html) {
  length(
    xml2::xml_find_all(
      xml2::xml_find_first(html, "//body"),
      # exclude dropdown headers
      sprintf("//h%s[not(contains(@class, 'dropdown'))]", level)
    )
  )
}

