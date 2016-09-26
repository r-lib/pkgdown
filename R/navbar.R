build_navbar <- function(meta, package) {
  meta <- meta_navbar(meta, package)

  path <- rmarkdown:::navbar_html(meta)
  on.exit(unlink(path), add = TRUE)

  paste(readLines(path), collapse = "\n")
}

meta_navbar <- function(meta, package) {
  if (!is.null(meta$navbar)) {
    return(meta$navbar)
  }

  list(
    title = meta$title %||% package$name,
    type = "default",
    left = list(
      list(
        text = "Home",
        href = "/"
      ),
      list(
        text = "Reference",
        href = "/reference/"
      ),
      list(
        text = "Articles",
        href = "/articles/"
      )
    )
  )
}
