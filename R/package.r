#' Generate pkgdown data structure
#'
#' You will generally not need to use this unless you need a custom site
#' design and you're writing your own equivalent of [build_site()].
#'
#' @param pkg Path to package.
#' @param override An optional named list used to temporarily override
#'   values in `_pkgdown.yml`
#' @export
as_pkgdown <- function(pkg = ".", override = list()) {
  if (is_pkgdown(pkg)) {
    return(pkg)
  }

  if (!dir_exists(pkg)) {
    stop("`pkg` is not an existing directory", call. = FALSE)
  }

  desc <- read_desc(pkg)
  meta <- read_meta(pkg)
  meta <- utils::modifyList(meta, override)

  package <- desc$get("Package")[[1]]
  version <- desc$get_field("Version")

  development <- meta_development(meta, version)

  if (is.null(meta$destination)) {
    dst_path <- path(pkg, "docs")
  } else {
    dst_path <- path_abs(meta$destination, start = pkg)
  }

  if (development$in_dev) {
    dst_path <- path(dst_path, development$destination)
  }

  structure(
    list(
      package = package,
      version = version,

      src_path = path_abs(pkg),
      dst_path = path_abs(dst_path),

      desc = desc,
      meta = meta,
      figures = meta_figures(meta),
      repo = package_repo(desc, meta),

      development = development,
      topics = package_topics(pkg, package),
      tutorials = package_tutorials(pkg, meta),
      vignettes = package_vignettes(pkg)
    ),
    class = "pkgdown"
  )
}

is_pkgdown <- function(x) inherits(x, "pkgdown")

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
    c("_pkgdown.yml",
      "_pkgdown.yaml",
      "pkgdown/_pkgdown.yml",
      "inst/_pkgdown.yml"
    )
  )

  if (is.null(path)) {
    yaml <- list()
  } else {
    yaml <- yaml::yaml.load_file(path) %||% list()
  }

  yaml
}

# Topics ------------------------------------------------------------------

package_topics <- function(path = ".", package = "pkgdown") {
  rd <- package_rd(path)

  aliases <- purrr::map(rd, extract_tag, "tag_alias")
  names <- purrr::map_chr(rd, extract_tag, "tag_name")
  titles <- purrr::map_chr(rd, extract_title)
  concepts <- unname(purrr::map(rd, extract_tag, "tag_concept"))
  keywords <- unname(purrr::map(rd, extract_tag, "tag_keyword"))
  internal <- purrr::map_lgl(keywords, ~ "internal" %in% .)
  source <- purrr::map(rd, extract_source)

  file_in <- names(rd)

  file_out <- gsub("\\.Rd$", ".html", file_in)
  file_out[file_out == "index.html"] <- "index-topic.html"

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
    keywords = keywords,
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
    str_trim()
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

# Vignettes ---------------------------------------------------------------

package_vignettes <- function(path = ".") {
  base <- path(path, "vignettes")

  if (!dir_exists(base)) {
    vig_path <- character()
  } else {
    vig_path <- dir_ls(base, regexp = "\\.[rR]md$", recurse = TRUE)
  }
  vig_path <- path_rel(vig_path, base)
  vig_path <- vig_path[!grepl("^_", path_file(vig_path))]
  vig_path <- vig_path[!grepl("^tutorials", path_dir(vig_path))]

  yaml <- purrr::map(path(base, vig_path), rmarkdown::yaml_front_matter)
  title <- purrr::map_chr(yaml, list("title", 1), .default = "UNKNOWN TITLE")
  desc <- purrr::map_chr(yaml, list("description", 1), .default = NA_character_)
  ext <- purrr::map_chr(yaml, c("pkgdown", "extension"), .default = "html")
  title[ext == "pdf"] <- paste0(title[ext == "pdf"], " (PDF)")

  tibble::tibble(
    name = path_ext_remove(vig_path),
    file_in = path("vignettes", vig_path),
    file_out = path("articles", paste0(path_ext_remove(vig_path), ".", ext)),
    title = title,
    description = desc
  )
}
