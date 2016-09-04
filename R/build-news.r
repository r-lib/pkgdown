build_news <- function(pkg) {
  if (!is.null(pkg$news_path)) {
    out <- file.path(paste0(pkg$news_path, ".html"))
    message("Generating NEWS page")
    pkg$news <- news(pkg, pkg$news_singlepage)
    render_page(pkg, "news", pkg, out)
    if (!pkg$news_singlepage) lapply(pkg$news, build_release, pkg = pkg)
  }
}

parse_release <- function(release, pkg = ".") {
  end_title <- regexpr("</h1>", release)[1]

  title <- substring(release, 1, end_title - 1)
  file_name <- paste0(gsub("\\s", "", title), ".html")
  path <- file.path(pkg$news_path, file_name)
  content <- substring(release, end_title + 5)

  context <- list(
    release_title = title,
    release_path = path,
    release_content = content)

  return(context)
}

build_release <- function(release, pkg = ".") {
  message("Generating ", release$release_title)
  render_page(pkg, "release", release, release$release_path)
}

news <- function(pkg = ".", singlepage) {
  # Look for NEWS.md in the package root
  path <- file.path(pkg$path, "NEWS.md")
  news <- list()
  if (file.exists(path)) {
    all <- markdown(path = path)
    if (singlepage) {
      news[[1]] <- list(release_all = all)
    } else {

      releases <- strsplit(all, "<h1>")[[1]]
      releases <- releases[releases != ""]

      for (i in seq_len(length(releases))) {
        news[[i]] <- parse_release(releases[i], pkg)
      }
    }
  }
  return(news)
}
