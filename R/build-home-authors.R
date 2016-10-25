data_home_sidebar_authors <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  authors <- tryCatch(eval(parse(text = pkg$desc$get_authors())),
    error = function(e) {
      warning(e)
      NULL
    }
  )
  if (is.null(authors))
    return()

  pkg$desc$get_authors() %>%
    unclass() %>%
    purrr::map_chr(author_desc, authors = pkg$meta$authors) %>%
    list_with_heading("Authors")
}

author_desc <- function(x, authors) {
  if (is.null(x$family)) {
    name <- x$given
  } else {
    name <- paste0(x$given, " ", x$family)
  }

  if (name %in% names(authors)) {
    author <- authors[[name]]

    if (!is.null(author$html)) {
      name <- author$html
    }

    if (!is.null(author$href)) {
      desc <- paste0("<a href='", author$href, "'>", name, "</a>")
    }
  } else {
    desc <- name
  }

  if (!is.null(x$comment)) {
    desc <- paste0(desc, " <small>", x$comment, "</small>")
  }

  roles <- paste0(role_lookup[x$role], collapse = ", ")
  substr(roles, 1, 1) <- toupper(substr(roles, 1, 1))
  desc <- paste0(desc, "<br /><small class = 'roles'>", roles, "</span>")

  desc
}

author_type <- function(x) {
  if ("cre" %in% x$role) {
    "cre"
  } else if ("aut" %in% x$role) {
    "aut"
  } else {
    "other"
  }
}

role_lookup <- c(
  "aut" = "author",
  "com" = "compiler",
  "ctb" = "contributor",
  "cph" = "copyright holder",
  "cre" = "maintainer",
  "ctr" = "contractor",
  "dtc" = "data contributor",
  "ths" = "thesis advisor",
  "trl" = "translator"
)

itemize <- function(header, x) {
  if (length(x) == 0)
    return()

  paste0(
    header, "\n",
    "\\itemize{\n",
    paste0("  \\item ", x, "\n", collapse = ""),
    "}\n"
  )
}
