build_home_md <- function(pkg, path, depth = 0) {

  mds <- dir_ls(pkg$src_path, glob = "*.md")
  excl <- path_file(mds) %in% c("README.md", "LICENSE.md", "NEWS.md", "cran-comments.md")
  mds <- mds[!excl]

  if (length(mds) == 0) {
    return()
  }

  lapply(mds, render_md, pkg = pkg)
}

render_md <- function(pkg, filename) {
  body <- markdown(path = filename, strip_header = TRUE)

  render_page(pkg, "title-body",
    data = list(pagetitle = attr(body, "title"), body = body),
    path = path_ext_set(basename(filename), "html")
  )
}
