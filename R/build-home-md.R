build_home_md <- function(pkg) {
  mds <- package_mds(pkg$src_path, in_dev = pkg$development$in_dev)

  lapply(mds, render_md, pkg = pkg)
  invisible()
}

package_mds <- function(path, in_dev = FALSE) {
  mds <- dir_ls(path, glob = "*.md")

  # Also looks in .github, if it exists
  github_path <- path(path, ".github")
  if (dir_exists(github_path)) {
    mds <- c(mds, dir_ls(github_path, glob = "*.md"))
  }

  # Remove files handled elsewhere
  handled <- c("README.md", "LICENSE.md", "LICENCE.md", "NEWS.md")
  mds <- mds[!path_file(mds) %in% handled]

  # Do not build 404 page if in-dev
  if (in_dev) {
    mds <- mds[path_file(mds) != "404.md"]
  }

  # Remove files that don't need to be rendered
  no_render <- c(
    "issue_template.md",
    "pull_request_template.md",
    "cran-comments.md"
  )
  mds <- mds[!path_file(mds) %in% no_render]

  unname(mds)
}

render_md <- function(pkg, filename) {
  cli::cli_inform("Reading {src_path(path_rel(filename, pkg$src_path))}")

  body <- markdown_body(pkg, filename, strip_header = TRUE)
  path <- path_ext_set(path_file(filename), "html")

  render_page(pkg, "title-body",
    data = list(
      pagetitle = attr(body, "title"),
      body = body,
      filename = filename,
      source = repo_source(pkg, path_rel(filename, pkg$src_path))
    ),
    path = path
  )

  if (path == "404.html") {
    update_html(path(pkg$dst_path, path), tweak_link_absolute, pkg = pkg)
  }
  check_missing_images(pkg, filename, path)

  invisible()
}
