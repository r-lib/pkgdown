article_index <- function(package) {
  if (is.null(package)) {
    context_get("article_index")
  } else if (is_devtools_package(package)) {
    # Use live docs for in-development packages
    article_index_local(package)
  } else {
    article_index_remote(package)
  }
}

article_index_local <- function(package, path = find.package(package)) {
  if (!is_installed(package)) {
    return(character())
  }

  src <- path(path, "vignettes")
  if (!dir_exists(src)) {
    return(character())
  }

  vig_path <- dir_ls(src, regexp = "\\.[rR]md$", recursive = TRUE, type = "file")

  out_path <- gsub("\\.[rR]md$", ".html", path_rel(vig_path, start = path_real(src)))
  vig_name <- gsub("\\.[rR]md$", "", path_file(vig_path))

  set_names(out_path, vig_name)
}

article_index_remote <- function(package) {
  # Ideally will use published metadata because that includes all articles
  # not just vignettes
  metadata <- remote_metadata(package)
  if (!is.null(metadata)) {
    return(metadata$articles)
  }

  # Otherwise, fallback to vignette index
  path <- system.file("Meta", "vignette.rds", package = package)
  if (path == "") {
    return(NULL)
  }

  meta <- readRDS(path)

  name <- tools::file_path_sans_ext(meta$File)
  set_names(meta$PDF, name)
}

find_article <- function(package, name) {
  index <- article_index(package)

  if (has_name(index, name)) {
    index[[name]]
  } else {
    NULL
  }
}
