build_citation_authors <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  source <- if (has_citation(pkg$src_path)) {
    repo_source(pkg, "inst/CITATION")
  } else {
    repo_source(pkg, "DESCRIPTION")
  }

  authors <- data_authors(pkg)
  data <- list(
    pagetitle = tr_("Authors and Citation"),
    citations = data_citations(pkg),
    authors = unname(authors$all),
    inst = authors$inst,
    before = authors$before,
    after = authors$after,
    source = source
  )

  render_page(pkg, "citation-authors", data, "authors.html")
}

data_authors <- function(pkg = ".", roles = default_roles(), call = caller_env()) {
  pkg <- as_pkgdown(pkg)
  author_info <- config_pluck_list(pkg, "authors", default = list(), call = call)

  inst_path <- path(pkg$src_path, "inst", "AUTHORS")
  if (file_exists(inst_path)) {
    inst <- read_lines(inst_path)
  } else {
    inst <- NULL
  }

  authors_all <- pkg_authors(pkg)
  authors_main <- pkg_authors(pkg, roles)

  all <- purrr::map(authors_all, author_list, author_info, pkg = pkg)
  main <- purrr::map(authors_main, author_list, author_info, pkg = pkg)
  more_authors <- length(main) != length(all)

  comments <- purrr::compact(purrr::map(all, "comment"))

  print_yaml(list(
    all = all,
    main = main,
    inst = inst,
    needs_page = more_authors || length(comments) > 0 || !is.null(inst),
    before = config_pluck_markdown_block(pkg, "authors.before", call = call),
    after = config_pluck_markdown_block(pkg, "authors.after", call = call)
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

data_home_sidebar_authors <- function(pkg = ".", call = caller_env()) {
  pkg <- as_pkgdown(pkg)

  config_pluck_list(pkg, "authors.sidebar")

  roles <- config_pluck_character(
    pkg,
    "authors.sidebar.roles",
    default = default_roles(),
    call = call
  )
  data <- data_authors(pkg, roles)
  authors <- purrr::map_chr(data$main, author_desc, comment = FALSE)

  before <- config_pluck_markdown_inline(pkg, "authors.sidebar.before", call = call)
  after <- config_pluck_markdown_inline(pkg, "authors.sidebar.after", call = call)

  bullets <- c(before, authors, after)
  if (data$needs_page) {
    bullets <- c(bullets, a(tr_("More about authors..."), "authors.html"))
  }

  sidebar_section(tr_("Developers"), bullets)
}

author_name <- function(x, authors, pkg) {
  name <- format_author_name(x$given, x$family)

  if (!(name %in% names(authors))) {
    return(name)
  }

  author <- authors[[name]]

  if (!is.null(author$html)) {
    error_path <- paste0("authors.", name, ".html")
    name <- markdown_text_inline(pkg, author$html, error_path = error_path)
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

author_list <- function(x, authors_info = NULL, comment = FALSE, pkg = ".") {
  name <- author_name(x, authors_info, pkg = pkg)

  roles <- paste0(role_lookup(x$role), collapse = ", ")
  substr(roles, 1, 1) <- toupper(substr(roles, 1, 1))

  orcid <- purrr::pluck(x$comment, "ORCID")
  x$comment <- remove_orcid(x$comment)

  ror <- purrr::pluck(x$comment, "ROR")
  x$comment <- remove_ror(x$comment)

  list(
    name = name,
    roles = roles,
    comment = linkify(x$comment),
    # can't have both ORCID and ROR
    uniqueid = orcid_link(orcid) %||% ror_link(ror)
  )
}

author_desc <- function(x, comment = TRUE) {
  paste(
    x$name,
    "<br />\n<small class = 'roles'>", x$roles, "</small>",
    if (!is.null(x$orcid)) {
      x$orcid
    },
    if (!is.null(x$ror)) {
      x$ror
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

ror_link <- function(ror) {
  if (is.null(ror)) {
    return(NULL)
  }

  paste0(
    "<a href='https://ror.org/", ror, "'>",
    "<img src='https://raw.githubusercontent.com/ror-community/ror-logos/main/ror-icon-rgb.svg' class='ror' alt='ROR'></a>"
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
    missing <- abbr[is.na(out)]
    cli::cli_warn("Unknown MARC role abbreviation{?s}: {.field {missing}}")
    out[is.na(out)] <- abbr[is.na(out)]
  }
  out
}

# citation ---------------------------------------------------------------------

has_citation <- function(path = ".") {
  file_exists(path(path, 'inst/CITATION'))
}

create_citation_meta <- function(path) {
  path <- path(path, "DESCRIPTION")

  dcf <- read.dcf(path)
  desc <- as.list(dcf[1, ])

  if (!is.null(desc$Encoding)) {
    desc <- lapply(desc, iconv, from = desc$Encoding, to = "UTF-8")
  } else {
    desc$Encoding <- "UTF-8"
  }

  if (!is.null(desc$Title)) desc$Title <- str_squish(desc$Title)

  desc
}

read_citation <- function(path = ".") {
  if (!has_citation(path)) {
    return(character())
  }
  meta <- create_citation_meta(path)
  cit_path <- path(path, 'inst/CITATION')

  utils::readCitationFile(cit_path, meta = meta)
}

data_home_sidebar_citation <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  sidebar_section(
    heading = tr_("Citation"),
    bullets = a(sprintf(tr_("Citing %s"), pkg$package), "authors.html#citation")
  )
}

data_citations <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  if (has_citation(pkg$src_path)) {
    return(citation_provided(pkg$src_path))
  }

  citation_auto(pkg)
}

citation_provided <- function(src_path) {
  provided_citation <- read_citation(src_path)

  text_version <- format(provided_citation, style = "textVersion")
  cit <- list(
    html = ifelse(
      text_version == "",
      format(provided_citation, style = "html"),
      paste0("<p>", escape_html(text_version), "</p>")
    ),
    bibtex = format(provided_citation, style = "bibtex")
  )

  purrr::transpose(cit)
}

citation_auto <- function(pkg) {
  desc <- read_desc(pkg$src_path)
  cit_info <- as.list(desc$get(desc$fields()))
  #  utils::packageDescription(
  #   pkg$package,
  #   lib.loc = path_dir(pkg$src_path)
  # )
  # browser()
# C
  cit_info$`Date/Publication` <- cit_info$`Date/Publication` %||% Sys.time()
  if (!is.null(cit_info$Title)) cit_info$Title <- str_squish(cit_info$Title)

  cit <- utils::citation(auto = cit_info)
  list(
    html = format(cit, style = "html"),
    bibtex = format(cit, style = "bibtex")
  )
}

# helpers -------------------------------------------------------------------------

# Not strictly necessary, but produces a simpler data structure testing
remove_orcid <- function(x) {
  out <- x[names2(x) != "ORCID"]
  if (all(names(out) == "")) {
    names(out) <- NULL
  }
  out
}
remove_ror <- function(x) {
  out <- x[names2(x) != "ROR"]
  if (all(names(out) == "")) {
    names(out) <- NULL
  }
  out
}
