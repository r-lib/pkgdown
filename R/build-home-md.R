build_home_md <- function(pkg, path, depth = 0) {

  mds <- fs::dir_ls(pkg$path, glob = "*.md")
  mds <- setdiff(mds, c("README.md", "LICENSE.md"))

  if (length(mds) == 0) {
    return()
  }

  lapply(mds, render_md, path = path, pkg = pkg, depth = depth)
}

render_md <- function(pkg, filename, path, depth = 0) {
  body <- markdown(path = filename, depth = depth)

  render_page(pkg, "title-body",
    data = list(pagetitle = filename, body = body),
    path = out_path(path, fs::path_ext_set(filename, "html"))
  )
}
