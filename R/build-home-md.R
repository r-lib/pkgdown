build_home_md <- function(pkg, path, depth = 0) {

  mds <- dir_ls(pkg$src_path, glob = "*.md")
  mds <- setdiff(mds, c("README.md", "LICENSE.md"))

  if (length(mds) == 0) {
    return()
  }

  lapply(mds, render_md, pkg = pkg)
}

render_md <- function(pkg, filename) {
  body <- markdown(path = filename)

  render_page(pkg, "title-body",
    data = list(pagetitle = filename, body = body),
    path = path_ext_set(basename(filename), "html")
  )
}
