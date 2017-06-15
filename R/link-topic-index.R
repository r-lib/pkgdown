# Compute topic index -----------------------------------------------------
# The topic index is a character vector that maps aliases to Rd file names
# (sans extension). Memoised for performance.

topic_index <- function(package) {
  if (is.null(package)) {
    cur_topic_index_get(check = TRUE)
  } else if (is_devtools_package(package)) {
    # Use live docs for in-development packages
    topic_index_local(package)
  } else {
    topic_index_installed(package)
  }
}

topic_index_local <- memoise(function(package) {
  topics <- package_topics(path = find.package(package))
  build_topic_index(topics)
})

build_topic_index <- function(topics) {
  aliases <- topics$alias
  names(aliases) <- gsub("\\.Rd$", "", topics$file_in)

  unlist(invert_index(aliases))
}

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

# Manage current topic index ----------------------------------------------------

cache <- new_environment()

cur_topic_index_set <- function(index) {
  old <- cur_topic_index_get()
  if (is.null(index) && env_has(cache, "topic_index")) {
    env_unbind(cache, "topic_index")
  } else {
    env_bind(cache, topic_index = index)
  }
  invisible(old)
}
cur_topic_index_get <- function(check = FALSE) {
  if (env_has(cache, "topic_index")) {
    env_get(cache, "topic_index")
  } else {
    if (check) {
      abort("Default topic index has not been initialised")
    }
    NULL
  }
}
