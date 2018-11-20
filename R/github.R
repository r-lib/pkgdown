# adapted from usethis R/browse.R
github_url_rx <- function() {
  paste0(
    "^",
    "(?:https?://github.com/)",
    "(?<owner>[^/]+)/",
    "(?<repo>[^/#]+)",
    "/?",
    "(?<fragment>.*)",
    "$"
  )
}

# adapted from usethis R/browse.R
#
## takes URL return by github_link() and strips it down to support
## appending path parts for issues or pull requests
##  input: "https://github.com/simsem/semTools/wiki"
## output: "https://github.com/simsem/semTools"
##  input: "https://github.com/r-lib/gh#readme"
## output: "https://github.com/r-lib/gh"
pkg_github_url <- function(desc) {
  urls <- desc$get_urls()
  gh_links <- grep("^https?://github.com/", urls, value = TRUE)

  if (length(gh_links) == 0) {
    return()
  }

  gh_link <- gsub("/$", "", gh_links[[1]])
  parse_github_link(gh_link)
}

parse_github_link <- function(link) {
  x <- rematch2::re_match(link, github_url_rx())
  paste0("https://github.com/", x$owner, "/", x$repo)
}

github_source <- function(base, paths) {
  # Don't need to touch those that are already a full url
  ifelse(
    grepl("^https?://", paths),
    paths,
    file.path(
      parse_github_link(base),
      "blob" , "master", paths
    )
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
  user_link <- paste0("\\1<a href='https://github.com/\\2'>@\\2</a>")
  x <- gsub("(\\s|^|\\()@([-\\w]+)", user_link, x, perl = TRUE)

  github_url <- pkg$github_url
  if (is.null(github_url)) {
    return(x)
  }

  issue_link <- paste0("<a href='", github_url, "/issues/\\1'>#\\1</a>")
  x <- gsub("#(\\d+)", issue_link, x)

  x
}
