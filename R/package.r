as_staticdocs <- function(path = ".") {
  if (is_staticdocs(path)) {
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
      vignettes = vignette_index(path),
      navbar = build_navbar(path)
    ),
    class = "staticdocs"
  )
}

is_staticdocs <- function(x) inherits(x, "staticdocs")

data_package <- function(x) {
  list(
    name = x$get("Package")[[1]],
    version = x$get("Version")[[1]],
    authors = purrr::map(x$get_authors(), str_person),
    license = x$get("License")
  )
}

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
  desc::description$new(file.path(path, "DESCRIPTION"))
}

# Metadata ----------------------------------------------------------------

read_meta <- function(path) {
  path <- find_meta(path)

  if (is.null(path)) {
    yaml <- list()
  } else {
    yaml <- yaml::yaml.load_file(path)
  }

  yaml
}

find_meta <- function(path) {
  path <- file.path(path, "_staticdocs.yml")
  if (file.exists(path)) {
    return(path)
  }

  path <- file.path(path, "_staticdocs.yaml")
  if (file.exists(path)) {
    return(path)
  }

  NULL
}


# Topics ------------------------------------------------------------------

topic_index <- function(path = ".") {
  rd <- package_rd(path)

  aliases <- purrr::map(rd, extract_tag, "tag_alias")
  names <- purrr::map_chr(rd, extract_tag, "tag_name")
  titles <- purrr::map_chr(rd, extract_tag, "tag_title")
  internal <- purrr::map_lgl(rd, is_internal)

  file_in <- names(rd)
  file_out <- gsub("\\.Rd$", ".html", file_in)

  tibble::tibble(
    name = names,
    file_in = file_in,
    file_out = file_out,
    alias = aliases,
    title = titles,
    rd = rd,
    internal = internal
  )
}

package_rd <- function(path) {
  man_path <- file.path(path, "man")
  rd <- dir(man_path, pattern = "\\.Rd$", full.names = TRUE)
  names(rd) <- basename(rd)
  lapply(rd, rd_file)
}

extract_tag <- function(x, tag) {
  x %>%
    purrr::keep(inherits, tag) %>%
    purrr::map_chr(c(1, 1))
}

is_internal <- function(x) {
  any(extract_tag(x, "tag_keyword") %in% "internal")
}


# Vignettes ---------------------------------------------------------------

vignette_index <- function(path = ".") {
  path <- dir(
    file.path(path, "vignettes"),
    pattern = "\\.Rmd$",
    recursive = TRUE
  )

  title <- file.path("vignettes", path) %>%
    purrr::map(yaml_metadata) %>%
    purrr::map_chr("title", .null = "UNKNOWN TITLE")

  tibble::tibble(
    file_in = path,
    file_out = gsub("\\.Rmd$", "\\.html", path),
    name = tools::file_path_sans_ext(path),
    title
  )
}

yaml_metadata <- function(path) {
  rmarkdown:::parse_yaml_front_matter(readLines(path))
}
