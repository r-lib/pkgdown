build_navbar <- function(meta = read_meta("."), desc = read_desc(".")) {
  meta <- meta_navbar(meta, desc)

  path <- rmarkdown:::navbar_html(meta)
  on.exit(unlink(path), add = TRUE)

  paste(readLines(path), collapse = "\n")
}

yaml_navbar <- function(path = ".") {
  meta <- meta_navbar(read_meta(path), read_desc(path))

  structure(
    yaml::as.yaml(meta),
    class = "yaml"
  )
}

#' @export
print.yaml <- function(x, ...) {
  cat(x, "\n", sep = "")
}

meta_navbar <- function(meta = read_meta("."), desc = read_desc(".")) {
  if (!is.null(meta$navbar)) {
    return(meta$navbar)
  }

  list(
    title = meta$title %||% desc$get("Name")[[1]],
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
    ),
    right = list(
      github_link(desc)
    )
  )
}


github_link <- function(desc) {
  if (!desc$has_fields("URL"))
    return()

  gh_links <- desc$get("URL")[[1]] %>%
    str_split(",") %>%
    `[[`(1) %>%
    str_trim() %>%
    str_subset("^https?://github.com/")

  if (length(gh_links) == 0)
    return()

  list(
    icon = "fa-github fa-lg",
    href = gh_links[[1]]
  )
}
