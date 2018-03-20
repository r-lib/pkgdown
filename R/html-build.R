a <- function(text, href) {
  ifelse(is.na(href), text, paste0("<a href='", href, "'>", text, "</a>"))
}

list_with_heading <- function(bullets, heading) {
  if (length(bullets) == 0)
    return(character())

  paste0(
    "<h2>", heading, "</h2>",
    "<ul class='list-unstyled'>\n",
    paste0("<li>", bullets, "</li>\n", collapse = ""),
    "</ul>\n"
  )
}

link_url <- function(text, href) {
  # Needs to handle NA for desc::desc_get()
  if (is.null(href) || identical(href, NA)) {
    return()
  }

  # insert zero-width spaces to allow for nicer line breaks
  label <- gsub("(/+)", "\\1&#8203;", href)
  paste0(text, " at <br /><a href='", href, "'>", label, "</a>")
}
