# @return An function that generates the navbar given the depth beneath
#   the docs root directory
data_navbar <- function(pkg = ".", depth = 0L) {
  pkg <- as_pkgdown(pkg)

  default <- default_navbar(pkg)

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

default_navbar <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  left <- list()

  left$home <- list(
    icon = "fa-home fa-lg",
    href = "index.html"
  )

  vignettes <- pkg$vignettes
  pkg_intro <- vignettes$name == pkg$package
  if (any(pkg_intro)) {
    intro <- vignettes[pkg_intro, , drop = FALSE]
    vignettes <- vignettes[!pkg_intro, , drop = FALSE]

    left$intro <- list(
      text = "Get Started",
      href = intro$file_out
    )
  }

  left$reference <- list(
    text = "Reference",
    href = "reference/index.html"
  )

  if (nrow(vignettes) > 0) {
    articles <- purrr::map2(
      vignettes$title, vignettes$file_out,
      ~ list(text = .x, href = .y)
    )

    left$articles <- list(
      text = "Articles",
      menu = articles
    )
  }

  releases_meta <- pkg$meta$news$releases
  if (!is.null(releases_meta)) {
    left$news <- list(
      text = "News",
      menu = c(
        list(list(text = "Releases")),
        releases_meta,
        list(
          list(text = "------------------"),
          list(
            text = "Changelog",
            href = "news/index.html"
          )
        )
      )
    )
  } else if (has_news(pkg$src_path)) {
    left$news <- list(
      text = "Changelog",
      href = "news/index.html"
    )
  }

  if (!is.null(pkg$github_url)) {
    right <- list(
      list(
        icon = "fa-github fa-lg",
        href = pkg$github_url
      )
    )
  } else {
    right <- list()
  }

  print_yaml(list(
    title = pkg$package,
    type = "default",
    left = unname(left),
    right = unname(right)
  ))
}
