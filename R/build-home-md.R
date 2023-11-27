build_home_md <- function(pkg) {

  mds <- dir_ls(pkg$src_path, glob = "*.md")

  # Also looks in .github, if it exists
  github_path <- path(pkg$src_path, ".github")
  if (dir_exists(github_path)) {
    mds <- c(mds, dir_ls(github_path, glob = "*.md"))
  }

  # Remove files handled elsewhere
  handled <- c("README.md", "LICENSE.md", "LICENCE.md", "NEWS.md", "cran-comments.md")
  mds <- mds[!path_file(mds) %in% handled]

  # Do not build 404 page if in-dev
  if (pkg$development$in_dev) {
    mds <- mds[fs::path_file(mds) != "404.md"]
  }

  lapply(mds, render_md, pkg = pkg)
  invisible()
}

render_md <- function(pkg, filename) {
  cli::cli_inform("Reading {src_path(path_rel(filename, pkg$src_path))}")

  body <- markdown_body(filename, strip_header = TRUE)
  path <- path_ext_set(basename(filename), "html")

  render_page(pkg, "title-body",
    data = list(
      pagetitle = attr(body, "title"),
      body = body,
      filename = filename,
      source = repo_source(pkg, fs::path_rel(filename, pkg$src_path))
    ),
    path = path
  )

  if (path == "404.html") {
    update_html(path(pkg$dst_path, path), tweak_link_absolute, pkg = pkg)
  }
  check_missing_images(pkg, filename, path)

  invisible()
}
