a <- function(text, href) {
  ifelse(is.na(href), text, paste0("<a href='", href, "'>", text, "</a>"))
}

link_url <- function(text, href) {
  if (!is.null(href)) {
    paste0("<a href='", href, "'>", text, "</a>")
  }
}

linkify <- function(text) {
  text <- escape_html(text)
  text <- gsub(
    "&lt;doi:([^&]+)&gt;", # DOIs with < > & are not supported
    "&lt;<a href='https://doi.org/\\1'>doi:\\1</a>&gt;",
    text,
    ignore.case = TRUE
  )
  text <- gsub(
    "&lt;arXiv:([^&]+)&gt;",
    "&lt;<a href='https://arxiv.org/abs/\\1'>arXiv:\\1</a>&gt;",
    text,
    ignore.case = TRUE
  )
  text <- gsub(
    "&lt;((http|ftp)[^&]+)&gt;", # URIs with & are not supported
    "&lt;<a href='\\1'>\\1</a>&gt;",
    text
  )
  text
}

dont_index <- function(x) {
  paste0("<div class='dont-index'>", x, "</div>")
}

escape_html <- function(x) {
  x <- gsub("&", "&amp;", x)
  x <- gsub("<", "&lt;", x)
  x <- gsub(">", "&gt;", x)
  # x <- gsub("'", "&#39;", x)
  # x <- gsub("\"", "&quot;", x)
  x
}

strip_html_tags <- function(x) gsub("<.*?>", "", x)
