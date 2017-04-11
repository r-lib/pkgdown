#' Generate pkgdown data structure
#'
#' You will generally not need to use this unless you need a custom site
#' design and you're writing your own equivalent of \code{\link{build_site}}.
#'
#' @param path Path to package
#' @export
as_pkgdown <- function(path = ".") {
  if (is_pkgdown(path)) {
    return(path)
  }

  if (!file.exists(path) || !is_dir(path)) {
    stop("`path` is not an existing directory", call. = FALSE)
  }

  structure(
    list(
      path = path,
      desc = read_desc(path),
      meta = read_meta(path),
      topics = topic_index(path),
      vignettes = vignette_index(path)
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
  path <- file.path(path, "DESCRIPTION")
  if (!file.exists(path)) {
    stop("Can't find DESCRIPTION", call. = FALSE)
  }
  desc::description$new(path)
}

# Metadata ----------------------------------------------------------------

read_meta <- function(path) {
  path <- find_first_existing(path, c("_pkgdown.yml", "_pkgdown.yaml"))

  if (is.null(path)) {
    yaml <- list()
  } else {
    yaml <- yaml::yaml.load_file(path)
  }

  yaml
}

# Topics ------------------------------------------------------------------

topic_index <- function(path = ".") {
  rd <- package_rd(path)

  aliases <- purrr::map(rd, extract_tag, "tag_alias")
  names <- purrr::map_chr(rd, extract_tag, "tag_name")
  titles <- purrr::map_chr(rd, extract_title)
  concepts <- purrr::map(rd, extract_tag, "tag_concept")
  internal <- purrr::map_lgl(rd, is_internal)

  file_in <- names(rd)
  file_out <- gsub("\\.Rd$", ".html", file_in)

  usage <- purrr::map(rd, topic_usage)
  funs <- purrr::map(usage, usage_funs)


  tibble::tibble(
    name = names,
    file_in = file_in,
    file_out = file_out,
    alias = aliases,
    usage = usage,
    funs = funs,
    title = titles,
    rd = rd,
    concepts = concepts,
    internal = internal
  )
}

package_rd <- function(path) {
  man_path <- file.path(path, "man")
  rd <- dir(man_path, pattern = "\\.Rd$", full.names = TRUE)
  names(rd) <- basename(rd)
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
    flatten_text() %>%
    trimws()
}

is_internal <- function(x) {
  any(extract_tag(x, "tag_keyword") %in% "internal")
}


# Vignettes ---------------------------------------------------------------

vignette_index <- function(path = ".") {
  vig_path <- dir(
    file.path(path, "vignettes"),
    pattern = "\\.Rmd$",
    recursive = TRUE
  )

  title <- file.path(path, "vignettes", vig_path) %>%
    purrr::map(rmarkdown::yaml_front_matter) %>%
    purrr::map_chr("title", .null = "UNKNOWN TITLE")

  tibble::tibble(
    file_in = vig_path,
    file_out = gsub("\\.Rmd$", "\\.html", vig_path),
    name = tools::file_path_sans_ext(basename(vig_path)),
    path = dirname(vig_path),
    vig_depth = dir_depth(vig_path),
    title = title
  )
}

dir_depth <- function(x) {
  x %>%
    strsplit("") %>%
    purrr::map_int(function(x) sum(x == "/"))
}


