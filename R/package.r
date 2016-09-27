as_staticdocs <- function(path = ".", options = list()) {
  if (is_staticdocs(path)) {
    return(path)
  }

  if (!file.exists(path) || !is_dir(path)) {
    stop("`path` is not an existing directory", call. = FALSE)
  }

  desc <- desc::description$new(file.path(path, "DESCRIPTION"))
  meta <- read_meta(path)
  package <- data_package(desc)

  structure(
    list(
      path = path,
      desc = desc,
      meta = meta,
      topics = topic_index(path),
      package = package,
      options = options,
      vignettes = vignette_index(path),
      navbar = build_navbar(meta, package, desc)
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
  aliases <- unname(lapply(rd, extract_alias))

  names <- purrr::map_chr(rd, extract_name)
  titles <- purrr::map_chr(rd, extract_title)
  internal <- purrr::map_lgl(rd, is_internal)

  file_in <- names(rd)
  file_out <- stringr::str_replace(file_in, "\\.Rd$", ".html")

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

extract_alias <- function(x) {
  aliases <- Filter(function(x) attr(x, "Rd_tag") == "\\alias", x)
  vapply(aliases, function(x) x[[1]][[1]], character(1))
}

extract_name <- function(x) {
  alias <- Find(function(x) attr(x, "Rd_tag") == "\\name", x)
  alias[[1]][[1]]
}

is_internal <- function(x) {
  keywords <- Find(function(x) attr(x, "Rd_tag") == "\\keyword", x)
  if (is.null(keywords))
    return(FALSE)

  any(purrr::map_chr(keywords, as.character) %in% "internal")
}

extract_title <- function(x, pkg) {
  title <- Find(function(x) attr(x, "Rd_tag") == "\\title", x)
  to_html(title, pkg = pkg)
}


# Vignettes ---------------------------------------------------------------

vignette_index <- function(path = ".") {
  path <- dir(
    file.path(path, "vignettes"),
    pattern = "\\.Rmd$",
    recursive = TRUE
  )

  title <- path %>%
    file.path("vignettes", .) %>%
    purrr::map(yaml_metadata) %>%
    purrr::map_chr("title", .null = "UNKNOWN TITLE")

  tibble::tibble(
    file_in = path,
    file_out = gsub("\\.Rmd$", "\\.html", path),
    title
  )
}

yaml_metadata <- function(path) {
  rmarkdown:::parse_yaml_front_matter(readLines(path))
}
