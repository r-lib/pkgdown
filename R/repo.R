repo_type <- function(pkg) {
  home <- repo_home(pkg) %||% ""

  if (grepl("^https?://github\\..+/", home)) {
    "github"
  } else if (grepl("^https?://gitlab\\..+/", home)) {
    "gitlab"
  } else if (grepl("^https?://codeberg\\..+/", home)) {
    "codeberg"
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

  needs_slash <- !grepl("/$", url$source) & !grepl("^/", paths)

  links <- a(
    paste0("<code>", escape_html(paths), "</code>"),
    paste0(url$source, ifelse(needs_slash, "/", ""), paths)
  )

  n <- length(links)
  if (n >= 4) {
    links <- c(links[1:3], paste0("and ", n - 3, " more"))
  }

  paste0(tr_("Source:"), " ", paste(links, collapse = ", "))
}

repo_auto_link <- function(pkg, text) {
  url <- pkg$repo$url

  if (!is.null(url$user)) {
    user_link <- paste0("\\1<a href='", url$user, "\\2'>@\\2</a>")
    text <- gsub("(p>|\\s|^|\\()@([-\\w]+)", user_link, text, perl = TRUE)
  }

  if (!is.null(url$issue)) {
    issue_link <- paste0("<a href='", url$issue, "\\2'>#\\2</a>")
    text <- gsub(
      "(p>|\\(|\\s)#(\\d+)",
      paste0("\\1", issue_link),
      text,
      perl = TRUE
    )

    if (!is.null(pkg$repo$jira_projects)) {
      issue_link <- paste0("<a href='", url$issue, "\\1\\2'>\\1\\2</a>")
      issue_regex <- paste0(
        "(",
        paste0(pkg$repo$jira_projects, collapse = "|"),
        ")(-\\d+)"
      )
      text <- gsub(issue_regex, issue_link, text, perl = TRUE)
    }
  }

  text
}

# Package data -------------------------------------------------------------

package_repo <- function(pkg) {
  # Use metadata if available
  repo <- config_pluck_list(pkg, "repo")
  url <- config_pluck_list(pkg, "repo.url")

  if (!is.null(url)) {
    return(repo)
  }

  # Otherwise try and guess from `BugReports` (1st priority) and `URL`s (2nd priority)
  urls <- c(
    sub(
      "(/-)?/issues/?",
      "/",
      pkg$desc$get_field("BugReports", default = character())
    ),
    pkg$desc$get_urls()
  )

  gh_links <- grep(
    "^https?://(git(hub|lab)|codeberg)\\..+/",
    urls,
    value = TRUE
  )
  if (length(gh_links) > 0) {
    branch <- config_pluck_string(pkg, "repo.branch")
    return(repo_meta_gh_like(gh_links[[1]], branch))
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
  branch <- branch %||% gha_current_branch()
  blob <- if (grepl("^https?://codeberg\\.", link)) "/src/branch/" else "/blob/"
  issues <- if (grepl("^https?://gitlab\\.", link)) "/-/issues/" else "/issues/"

  repo_meta(
    paste0(gh$host, "/", gh$owner, "/", gh$repo, "/"),
    paste0(gh$host, "/", gh$owner, "/", gh$repo, blob, branch, "/"),
    paste0(gh$host, "/", gh$owner, "/", gh$repo, issues),
    paste0(gh$host, "/")
  )
}

gha_current_branch <- function() {
  # Only set in pull requests
  ref <- Sys.getenv("GITHUB_HEAD_REF")
  if (ref != "") {
    return(ref)
  }

  # Set everywhere but might not be a branch
  ref <- Sys.getenv("GITHUB_REF_NAME")
  if (ref != "") {
    return(ref)
  }

  "HEAD"
}

parse_github_like_url <- function(link) {
  supports_subgroups <- grepl("^https?://gitlab\\.", link)
  rx <- paste0(
    "^",
    "(?<host>https?://[^/]+)/",
    "(?<owner>[^/]+)/",
    "(?<repo>[^#",
    "/"[!supports_subgroups],
    "]+)/"
  )
  re_match(sub("([^/]$)", "\\1/", link), rx)
}
