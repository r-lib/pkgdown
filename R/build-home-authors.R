data_authors <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)
  author_info <- data_author_info(pkg)

  all <- pkg %>%
    pkg_authors() %>%
    purrr::map(author_list, author_info)

  main <- pkg %>%
    pkg_authors(c("aut", "cre", "fnd")) %>%
    purrr::map(author_list, author_info)

  needs_page <- length(main) != length(all)

  print_yaml(list(
    all = all,
    main = main,
    needs_page = needs_page
  ))
}

pkg_authors <- function(pkg, role = NULL) {
  authors <- unclass(pkg$desc$get_authors())

  if (is.null(role)) {
    authors
  } else {
    purrr::keep(authors, ~ any(.$role %in% role))
  }
}


data_author_info <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  defaults <- list(
    "Hadley Wickham" = list(
      href = "http://hadley.nz"
    ),
    "RStudio" = list(
      href = "https://www.rstudio.com",
      html = "<img src='http://tidyverse.org/rstudio-logo.svg' height='24' />"
    )
  )

  utils::modifyList(defaults, pkg$meta$authors %||% list())
}


data_home_sidebar_authors <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)
  data <- data_authors(pkg)

  authors <- data$main %>% purrr::map_chr(author_desc)
  if (data$needs_page) {
    authors <- c(authors, "<a href='authors.html'>All authors...</li>")
  }

  list_with_heading(authors, "Developers")
}

build_authors <- function(pkg = ".", path = "docs", depth = 0L) {
  pkg <- as_pkgdown(pkg)

  data <- list(
    pagetitle = "Authors",
    authors = data_authors(pkg)$all
  )

  render_page(pkg, "authors", data, file.path(path, "authors.html"), depth = depth)
}

author_name <- function(x, authors) {
  name <- format_author_name(x$given, x$family)

  if (!(name %in% names(authors)))
    return(name)

  author <- authors[[name]]

  if (!is.null(author$html)) {
    name <- author$html
  }

  if (is.null(author$href)) {
    name
  } else {
    paste0("<a href='", author$href, "'>", name, "</a>")
  }
}

format_author_name <- function(given, family) {
  given <- paste(given, collapse = " ")

  if (is.null(family)) {
    given
  } else {
    paste0(given, " ", family)
  }
}

author_list <- function(x, authors_info, comment = FALSE) {
  name <- author_name(x, authors_info)

  roles <- paste0(role_lookup[x$role], collapse = ", ")
  substr(roles, 1, 1) <- toupper(substr(roles, 1, 1))

  list(
    name = name,
    roles = roles,
    comment = x$comment
  )
}

author_desc <- function(x, comment = TRUE) {
  paste(
    x$name,
    "<br />\n<small class = 'roles'>", x$roles, "</small>",
    if (comment && !is.null(x$comment))
      paste0("<br/>\n<small>(", x$comment, ")</small>")
  )
}

role_lookup <- c(
  "aut" = "author",
  "com" = "compiler",
  "fnd" = "funder",
  "ctb" = "contributor",
  "cph" = "copyright&nbsp;holder",
  "cre" = "maintainer",
  "ctr" = "contractor",
  "dtc" = "data&nbsp;contributor",
  "ths" = "thesis&nbsp;advisor",
  "trl" = "translator"
)
