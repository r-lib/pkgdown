# Compute topic index -----------------------------------------------------
# The topic index is a character vector that maps aliases to Rd file names
# (sans extension). Memoised for performance.

topic_index <- function(package) {
  if (is.null(package)) {
    context_get("topic_index")
  } else if (is_devtools_package(package)) {
    # Use live docs for in-development packages
    topic_index_local(package)
  } else {
    topic_index_installed(package)
  }
}

topic_index_local <- memoise(function(package, path = find.package(package)) {
  if (!is_installed(package)) {
    return(character())
  }

  rd <- package_rd(path)
  aliases <- purrr::map(rd, extract_tag, "tag_alias")
  names(aliases) <- gsub("\\.Rd$", "", names(rd))

  unlist(invert_index(aliases))
})


topic_index_installed <- memoise(function(package) {
  path <- system.file("help", "aliases.rds", package = package)
  if (path == "")
    return(NULL)

  readRDS(path)
})

is_devtools_package <- function(x) {
  if (!isNamespaceLoaded(x)) {
    return(FALSE)
  }

  ns <- .getNamespace(x)
  env_has(ns, ".__DEVTOOLS__")
}

# A helper that can warn if the topic is not found
find_rdname <- function(package, topic, warn_if_not_found = FALSE) {
  index <- topic_index(package)

  if (has_name(index, topic)) {
    index[[topic]]
  } else {
    if (warn_if_not_found) {
      warn(paste0("Failed to find topic `", topic, "`"))
    }
    NULL
  }
}

find_rdname_local <- function(topic) {
  find_rdname(NULL, topic)
}

find_rdname_attached <- function(topic) {
  for (package in context_get("packages")) {
    rdname <- find_rdname(package, topic)
    if (!is.null(rdname)) {
      return(list(rdname = rdname, package = package))
    }
  }
  NULL
}
