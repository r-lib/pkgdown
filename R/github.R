pkg_github_url <- function(desc) {
  if (!desc$has_fields("URL"))
    return()

  gh_links <- desc$get("URL")[[1]] %>%
    strsplit(",") %>%
    `[[`(1) %>%
    trimws()
  gh_links <- grep("^https?://github.com/", gh_links, value = TRUE)

  if (length(gh_links) == 0)
    return()

  gh_links[[1]]
}

github_source <- function(base, paths) {
  # Don't need to touch those that are already a full url
  ifelse(
    grepl("^https?://", paths),
    paths,
    file.path(base, "blob" , "master", paths)
  )
}

github_source_links <- function(base, paths) {
  if (is.null(base) || length(paths) == 0) {
    return(character())
  }

  source_links <- paste0(
    "<a href='", github_source(base, paths), "'>",
    "<code>", escape_html(paths), "</code></a>"
  )

  n <- length(source_links)
  if (n >= 4) {
    source_links <- c(
      source_links[1:3],
      paste0("and ", n - 2, " more")
    )
  }

  paste0("Source: ", paste(source_links, collapse = ", "))
}

add_github_links <- function(x, pkg) {
  user_link <- paste0("<a href='http://github.com/\\1'>@\\1</a>")
  x <- gsub("@(\\w+)", user_link, x)

  github_url <- pkg$github_url
  if (is.null(github_url)) {
    return(x)
  }

  issue_link <- paste0("<a href='", github_url, "/issues/\\1'>#\\1</a>")
  x <- gsub("#(\\d+)", issue_link, x)

  x
}
