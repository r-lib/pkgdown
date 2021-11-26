data_authors <- function(pkg = ".", roles = default_roles()) {
  pkg <- as_pkgdown(pkg)
  author_info <- data_author_info(pkg)

  all <- pkg %>%
    pkg_authors() %>%
    purrr::map(author_list, author_info, pkg = pkg)

  main <- pkg %>%
    pkg_authors(roles) %>%
    purrr::map(author_list, author_info, pkg = pkg)

  more_authors <- length(main) != length(all)

  comments <- pkg %>%
    pkg_authors() %>%
    purrr::map(author_list, author_info, pkg = pkg) %>%
    purrr::map("comment") %>%
    purrr::compact() %>%
    length() > 0

  print_yaml(list(
    all = all,
    main = main,
    needs_page = more_authors || comments
  ))
}

default_roles <- function() {
  c("aut", "cre", "fnd")
}

pkg_authors <- function(pkg, role = NULL) {
  if (pkg$desc$has_fields("Authors@R")) {
    authors <- unclass(pkg$desc$get_authors())
  } else {
    # Just show maintainer
    authors <- unclass(utils::as.person(pkg$desc$get_maintainer()))
    authors[[1]]$role <- "cre"
  }

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
      html = "<img src='https://www.tidyverse.org/rstudio-logo.svg' alt='RStudio' width='72' />"
    ),
    "R Consortium" = list(
      href = "https://www.r-consortium.org"
    )
  )

  utils::modifyList(defaults, pkg$meta$authors %||% list())
}


data_home_sidebar_authors <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)
  roles <- pkg$meta$authors$sidebar$roles %||% default_roles()
  data <- data_authors(pkg, roles)

  authors <- data$main %>% purrr::map_chr(author_desc, comment = FALSE)

  bullets <- c(
    markdown_text_inline(
      pkg$meta$authors$sidebar$before,
      pkg = pkg,
      where = c("authors", "sidebar", "before")
    ),
    authors,
    markdown_text_inline(
      pkg$meta$authors$sidebar$after,
      pkg = pkg,
      where = c("authors", "sidebar", "after")
    )
  )

  if (data$needs_page) {
    bullets <- c(bullets, a(tr_("More about authors..."), "authors.html"))
  }

  sidebar_section(tr_("Developers"), bullets)
}

data_authors_page <- function(pkg) {
  data <- list(
    pagetitle = tr_("Authors"),
    authors = data_authors(pkg)$all
  )

  data$before <- markdown_text_block(pkg$meta$authors$before, pkg = pkg)
  data$after <- markdown_text_block(pkg$meta$authors$after, pkg = pkg)

  return(data)
}

author_name <- function(x, authors, pkg) {
  name <- format_author_name(x$given, x$family)

  if (!(name %in% names(authors))) {
    return(name)
  }

  author <- authors[[name]]

  if (!is.null(author$html)) {
    name <- markdown_text_inline(
      author$html,
      pkg = pkg,
      where = c("authors", name, "html")
    )
  }

  if (is.null(author$href)) {
    name
  } else {
    a(name, author$href)
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

author_list <- function(x, authors_info = NULL, comment = FALSE, pkg) {
  name <- author_name(x, authors_info, pkg = pkg)

  roles <- paste0(role_lookup(x$role), collapse = ", ")
  substr(roles, 1, 1) <- toupper(substr(roles, 1, 1))

  orcid <- purrr::pluck(x$comment, "ORCID")
  x$comment <- remove_name(x$comment, "ORCID")

  list(
    name = name,
    roles = roles,
    comment = x$comment,
    orcid = orcid_link(orcid)
  )
}

author_desc <- function(x, comment = TRUE) {
  paste(
    x$name,
    "<br />\n<small class = 'roles'>", x$roles, "</small>",
    if (!is.null(x$orcid)) {
      x$orcid
    },
    if (comment && !is.null(x$comment) && length(x$comment) != 0) {
      paste0("<br/>\n<small>(", linkify(x$comment), ")</small>")
    }
  )
}

orcid_link <- function(orcid) {
  if (is.null(orcid)) {
    return(NULL)
  }

  paste0(
    "<a href='https://orcid.org/", orcid, "' target='orcid.widget' aria-label='ORCID'>",
    "<span class='fab fa-orcid orcid' aria-hidden='true'></span></a>"
  )
}

# Derived from:
# db <- utils:::MARC_relator_db
# db <- db[db$usage != "",]
# dput(setNames(tolower(db$term), db$code))
# # and replace creater with maintainer
role_lookup <- function(abbr) {
  # CRAN roles are translated
  roles <- c(
    aut = tr_("author"),
    com = tr_("compiler"),
    ctr = tr_("contractor"),
    ctb = tr_("contributor"),
    cph = tr_("copyright holder"),
    cre = tr_("maintainer"),
    dtc = tr_("data contributor"),
    fnd = tr_("funder"),
    rev = tr_("reviewer"),
    ths = tr_("thesis advisor"),
    trl = tr_("translator")
  )

  # Other roles are left as is
  marc_db <- getNamespace("utils")$MARC_relator_db
  extra <- setdiff(marc_db$code, names(roles))
  roles[extra] <- tolower(marc_db$term[match(extra, marc_db$code)])

  out <- unname(roles[abbr])
  if (any(is.na(out))) {
    missing <- paste0("'", abbr[is.na(out)], "'", collapse = ", ")
    warn(paste0("Unknown MARC role abbreviation ", missing))
    out[is.na(out)] <- abbr[is.na(out)]
  }
  out
}

# helpers -----------------------------------------------------------------

remove_name <- function(x, name) {
  stopifnot(is.character(name), length(name) == 1)

  nms <- names(x)
  if (is.null(nms)) {
    return(x)
  }

  out <- x[!(nms %in% name)]
  if (all(names(out) == "")) {
    names(out) <- NULL
  }
  out
}
