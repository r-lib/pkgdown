# @return An function that generates the navbar given the depth beneath
#   the docs root directory
build_navbar <- function(path = ".") {
  navbar <- read_navbar(path)

  function(depth = 0L) {
    navbar <- tweak_links(navbar, depth)

    path <- rmarkdown::navbar_html(navbar)
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


read_navbar <- function(path = ".") {
  meta <- read_meta(path)
  default <- default_navbar(path)
  navbar <- meta$navbar %||% default
  navbar$right <- navbar$right %||% default$right
  navbar$title <- meta$title %||% read_desc(path)$get("Package")[[1]]

  print_yaml(navbar)
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

# Default navbar ----------------------------------------------------------

default_navbar <- function(path = ".") {
  list(
    type = "default",
    left = purrr::compact(list(
      list(
        text = "Home",
        href = "index.html"
      ),
      list(
        text = "Reference",
        href = "reference/index.html"
      ),
      if (has_vignettes(path)) {
        list(
          text = "Articles",
          href = "articles/index.html"
        )
      },
      if (has_news(path)) {
        list(
          text = "News",
          href = "news/index.html"
        )
      }
    )),
    right = purrr::compact(list(
      github_link(path)
    ))
  )
}

github_link <- function(path = ".") {
  desc <- read_desc(path)

  if (!desc$has_fields("URL"))
    return()

  gh_links <- desc$get("URL")[[1]] %>%
    strsplit(",") %>%
    `[[`(1) %>%
    trimws()
  gh_links <- grep("^https?://github.com/", gh_links, value = TRUE)

  if (length(gh_links) == 0)
    return()

  list(
    icon = "fa-github fa-lg",
    href = gh_links[[1]]
  )
}
