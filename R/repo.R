repo_type <- function(pkg) {
  home <- repo_home(pkg) %||% ""

  if (grepl("^https?://github\\..+/", home)) {
    "github"
  } else if (grepl("^https?://gitlab\\..+/", home)) {
    "gitlab"
  } else {
    "other"
  }
}

repo_home <- function(pkg, paths) {
  pkg$repo$url$home
}

repo_source <- function(pkg, paths) {
  url <- pkg$repo$url
  if (is.null(url$source) || length(paths) == 0) {
    return()
  }

  links <- a(
    paste0("<code>", escape_html(paths), "</code>"),
    paste0(url$source, paths)
  )

  n <- length(links)
  if (n >= 4) {
    links <- c(links[1:3], paste0("and ", n - 3, " more"))
  }

  paste0("Source: ", paste(links, collapse = ", "))
}

repo_auto_link <- function(pkg, text) {
  url <- pkg$repo$url

  if (!is.null(url$user)) {
    user_link <- paste0("\\1<a href='", url$user, "\\2'>@\\2</a>")
    text <- gsub("(\\s|^|\\()@([-\\w]+)", user_link, text, perl = TRUE)
  }

  if (!is.null(url$issue)) {
    issue_link <- paste0("<a href='", url$issue, "\\2'>#\\2</a>")
    text <- gsub("(\\(|\\s)#(\\d+)", paste0("\\1", issue_link), text, perl = TRUE)

    if (!is.null(pkg$repo$jira_projects)) {
      issue_link <- paste0("<a href='", url$issue, "\\1\\2'>\\1\\2</a>")
      issue_regex <- paste0("(", paste0(pkg$repo$jira_projects, collapse = "|"),")(-\\d+)")
      text <- gsub(issue_regex, issue_link, text, perl = TRUE)
    }
  }

  text
}

# Package data -------------------------------------------------------------

package_repo <- function(desc, meta) {
  # Use metadata if available
  if (has_name(meta, "repo") && has_name(meta[["repo"]], "url")) {
    return(meta[["repo"]])
  }

  # Otherwise try and guess from BugReports + URLs
  urls <- c(
    desc$get_field("BugReports", default = character()),
    desc$get_urls()
  )

  gh_links <- grep("^https?://git(hub|lab)\\..+/", urls, value = TRUE)
  if (length(gh_links) > 0) {
    return(repo_meta_gh_like(gh_links[[1]], meta[["repo"]][["branch"]]))
  }

  NULL
}

repo_meta <- function(home = NULL, source = NULL, issue = NULL, user = NULL) {
  list(
    url = list(
      home = home,
      source = source,
      issue = issue,
      user = user
    )
  )
}

repo_meta_gh_like <- function(link, branch = NULL) {
  gh <- parse_github_like_url(link)
  branch <- branch %||% "master"
  repo_meta(
    paste0(gh$host, "/", gh$owner, "/", gh$repo, "/"),
    paste0(gh$host, "/", gh$owner, "/", gh$repo, "/blob/", branch, "/"),
    paste0(gh$host, "/", gh$owner, "/", gh$repo, "/issues/"),
    paste0(gh$host, "/")
  )
}

# adapted from usethis:::github_link()
parse_github_like_url <- function(link) {
  rx <- paste0(
    "^",
    "(?<host>https?://[^/]+)/",
    "(?<owner>[^/]+)/",
    "(?<repo>[^/#]+)"
  )
  re_match(link, rx)
}
