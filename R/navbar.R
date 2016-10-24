# @return An function that generates the navbar given the depth beneath
#   the docs root directory
data_navbar <- function(pkg = ".", depth = 0L) {
  pkg <- as_pkgdown(pkg)

  default <- default_navbar(pkg$path, pkg$desc$get("Package")[[1]])

  navbar <- list(
    title =  pkg$meta$navbar$title %||% default$title,
    type =   pkg$meta$navbar$type  %||% default$type,
    left =   pkg$meta$navbar$left  %||% default$left,
    right =  pkg$meta$navbar$right  %||% default$right
  )

  navbar$left <- render_navbar_links(navbar$left, depth = depth)
  navbar$right <- render_navbar_links(navbar$right, depth = depth)

  print_yaml(navbar)
}

render_navbar_links <- function(x, depth = 0L) {
  stopifnot(is.integer(depth), depth >= 0L)

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

  if (depth != 0L) {
    x <- lapply(x, tweak)
  }
  rmarkdown::navbar_links_html(x)
}

# Default navbar ----------------------------------------------------------

default_navbar <- function(path = ".", title = NULL) {
  list(
    title = title,
    type = "default",
    left = purrr::compact(list(
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
