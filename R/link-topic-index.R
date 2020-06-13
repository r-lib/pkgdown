# Compute topic index -----------------------------------------------------
# The topic index is a character vector that maps aliases to Rd file names
# (sans extension). Memoised for performance.

topic_index <- function(package) {
  if (is.null(package)) {
    context_get("topic_index")
  } else if (devtools_loaded(package)) {
    # Use live docs for in-development packages
    topic_index_local(package)
  } else {
    topic_index_installed(package)
  }
}

topic_index_local <- memoise(function(package, path = NULL) {
  if (!is_installed(package)) {
    return(character())
  }

  if (is.null(path)) {
    path <- find.package(package)
  }

  rd <- package_rd(path)
  aliases <- purrr::map(rd, extract_tag, "tag_alias")
  names(aliases) <- gsub("\\.Rd$", "", names(rd))

  unlist(invert_index(aliases))
})


topic_index_installed <- memoise(function(package) {
  path <- system.file("help", "aliases.rds", package = package)
  if (path == "")
    return(character())

  readRDS(path)
})
