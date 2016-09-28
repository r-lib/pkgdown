# @return An function that generates the navbar given the depth beneath
#   the docs root directory
build_navbar <- function(meta = read_meta("."), desc = read_desc(".")) {
  meta <- meta_navbar(meta, desc)

  function(depth = 0L) {
    meta <- tweak_links(meta, depth)

    path <- rmarkdown:::navbar_html(meta)
    on.exit(unlink(path), add = TRUE)

    # Patch home href
    lines <- readLines(path)
    lines <- sub(
      '<a class="navbar-brand" href="index.html">',
      paste0('<a class="navbar-brand" href="', up_path(depth), 'index.html">'),
      lines,
      fixed = TRUE
    )

    paste(lines, collapse = "\n")
  }
}

yaml_navbar <- function(path = ".") {
  meta <- meta_navbar(read_meta(path), read_desc(path))
  full <- list(navbar = meta)

  structure(
    yaml::as.yaml(full),
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
    title = meta$title %||% desc$get("Package")[[1]],
    type = "default",
    left = list(
      list(
        text = "Home",
        href = "index.html"
      ),
      list(
        text = "Reference",
        href = "reference/index.html"
      ),
      list(
        text = "Articles",
        href = "articles/index.html"
      )
    ),
    right = list(
      github_link(desc)
    )
  )
}


tweak_links <- function(x, depth = 1L) {
  stopifnot(is.integer(depth), depth >= 0L)

  if (depth == 0L) {
    return(x)
  }

  tweak <- function(x) {
    if (!is.null(x$menu)) {
      x$menu <- lapply(x$menu, tweak)
      x
    } else if (!is.null(x$href) && !grepl("://", x$href, fixed = TRUE)) {
      x$href <- paste0(up_path(depth), x$href)
      x
    } else {
      x
    }
  }

  x$left <- lapply(x$left, tweak)
  x$right <- lapply(x$right, tweak)

  x
}

github_link <- function(desc) {
  if (!desc$has_fields("URL"))
    return()

  gh_links <- desc$get("URL")[[1]] %>%
    strsplit(",") %>%
    `[[`(1) %>%
    trimws() %>%
    grep("^https?://github.com/", value = TRUE)

  if (length(gh_links) == 0)
    return()

  list(
    icon = "fa-github fa-lg",
    href = gh_links[[1]]
  )
}
