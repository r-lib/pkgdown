#' Generate pkgdown data structure
#'
#' You will generally not need to use this unless you need a custom site
#' design and you're writing your own equivalent of [build_site()].
#'
#' @param path Path to package
#' @export
as_pkgdown <- function(path = ".") {
  if (is_pkgdown(path)) {
    return(path)
  }

  if (!dir_exists(path)) {
    stop("`path` is not an existing directory", call. = FALSE)
  }

  desc <- read_desc(path)
  package <- desc$get("Package")[[1]]
  topics <- package_topics(path, package)

  meta <- read_meta(path)

  if (is.null(meta$destination)) {
    dst_path <- path(path, "docs")
  } else {
    dst_path <- path_abs(meta$destination, start = path)
  }

  structure(
    list(
      package = package,
      src_path = path_abs(path),
      dst_path = path_abs(dst_path),
      github_url = pkg_github_url(desc),
      desc = desc,
      meta = meta,
      topics = topics,
      vignettes = package_vignettes(path),
      topic_index = topic_index_local(package, path),
      article_index = article_index_local(package, path)
    ),
    class = "pkgdown"
  )
}

is_pkgdown <- function(x) inherits(x, "pkgdown")

str_person <- function(pers) {
  s <- paste0(c(pers$given, pers$family), collapse = ' ')

  if (length(pers$email)) {
    s <- paste0("<a href='mailto:", pers$email, "'>", s, "</a>")
  }
  if (length(pers$role)) {
    s <- paste0(s, " [", paste0(pers$role, collapse = ", "), "]")
  }
  s
}

read_desc <- function(path = ".") {
  path <- path(path, "DESCRIPTION")
  if (!file_exists(path)) {
    stop("Can't find DESCRIPTION", call. = FALSE)
  }
  desc::description$new(path)
}

# Metadata ----------------------------------------------------------------

read_meta <- function(path) {
  path <- path_first_existing(
    path,
    c("_pkgdown.yml", "pkgdown/_pkgdown.yml", "_pkgdown.yaml")
  )

  if (is.null(path)) {
    yaml <- list()
  } else {
    yaml <- yaml::yaml.load_file(path)
  }

  yaml
}

# Topics ------------------------------------------------------------------

package_topics <- function(path = ".", package = "pkgdown") {
  rd <- package_rd(path)

  # In case there are links in titles
  scoped_package_context(package, src_path = path)
  scoped_file_context()

  aliases <- purrr::map(rd, extract_tag, "tag_alias")
  names <- purrr::map_chr(rd, extract_tag, "tag_name")
  titles <- purrr::map_chr(rd, extract_title)
  concepts <- purrr::map(rd, extract_tag, "tag_concept")
  internal <- purrr::map_lgl(rd, is_internal)
  source <- purrr::map(rd, extract_source)

  file_in <- names(rd)
  file_out <- gsub("\\.Rd$", ".html", file_in)

  funs <- purrr::map(rd, topic_funs)

  tibble::tibble(
    name = names,
    file_in = file_in,
    file_out = file_out,
    alias = aliases,
    funs = funs,
    title = titles,
    rd = rd,
    source = source,
    concepts = concepts,
    internal = internal
  )
}

package_rd <- function(path = ".") {
  man_path <- path(path, "man")

  if (!dir_exists(man_path)) {
    return(set_names(list(), character()))
  }

  rd <- dir_ls(man_path, regexp = "\\.[Rr]d$", type = "file")
  names(rd) <- path_file(rd)
  lapply(rd, rd_file, pkg_path = path)
}

extract_tag <- function(x, tag) {
  x %>%
    purrr::keep(inherits, tag) %>%
    purrr::map_chr(c(1, 1))
}

extract_title <- function(x) {
  x %>%
    purrr::detect(inherits, "tag_title") %>%
    flatten_text(auto_link = FALSE) %>%
    trimws()
}

extract_source <- function(x) {
  nl <- purrr::map_lgl(x, inherits, "TEXT") & x == "\n"
  comment <- purrr::map_lgl(x, inherits, "COMMENT")

  first_comment <- cumsum(!(nl | comment)) == 0
  lines <- as.character(x[first_comment])
  text <- paste0(lines, collapse = "")

  if (!grepl("roxygen2", text)) {
    return(character())
  }

  m <- gregexpr("R/[^ ]+\\.[rR]", text)
  regmatches(text, m)[[1]]
}

is_internal <- function(x) {
  any(extract_tag(x, "tag_keyword") %in% "internal")
}


# Vignettes ---------------------------------------------------------------

package_vignettes <- function(path = ".") {
  base <- path(path, "vignettes")

  if (!dir_exists(base)) {
    vig_path <- character()
  } else {
    vig_path <- dir_ls(base, regexp = "\\.[rR]md$", recursive = TRUE)
  }
  vig_path <- path_rel(vig_path, base)
  vig_path <- vig_path[!grepl("^_", path_file(vig_path))]

  yaml <- purrr::map(path(base, vig_path), rmarkdown::yaml_front_matter)
  title <- purrr::map_chr(yaml, "title", .default = "UNKNOWN TITLE")
  ext <- purrr::map_chr(yaml, c("pkgdown", "extension"), .default = "html")
  title[ext == "pdf"] <- paste0(title[ext == "pdf"], " (PDF)")

  tibble::tibble(
    name = path_ext_remove(vig_path),
    file_in = path("vignettes", vig_path),
    file_out = path("articles", path_ext_set(vig_path, ext)),
    title = title
  )
}
