github_url_regex <- "^https?://github\\.com/"

pkg_github_url <- function(desc, meta = list()) {
  if (!desc$has_fields("URL"))
    return()

  gh_links <- desc$get("URL")[[1]] %>%
    strsplit(",") %>%
    `[[`(1) %>%
    str_trim()

  github_url <- purrr::pluck(meta, "news", "github_url")
  if (!is.null(github_url)) {
    gh_links <- grep(github_url, gh_links, value = TRUE, fixed = TRUE)
  } else {
    gh_links <- grep(github_url_regex, gh_links, value = TRUE)
  }

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
  github_url <- pkg$github_url

  if (is.null(github_url) || grepl(github_url_regex, github_url)) {
    user_link <- paste0("<a href='http://github.com/\\1'>@\\1</a>")
    x <- gsub("@(\\w+)", user_link, x)
  }

  if (is.null(github_url)) {
    return(x)
  }

  issue_link <- paste0("<a href='", github_url, "/issues/\\1'>#\\1</a>")
  x <- gsub("#(\\d+)", issue_link, x)

  x
}
