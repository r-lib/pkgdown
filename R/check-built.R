
check_built_site <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  cli::cli_rule("Checking for problems")
  index_path <- path_index(pkg)
  if (!is.null(index_path)) {
    check_missing_images(pkg, index_path, "index.html")
  }
}

check_missing_images <- function(pkg, src_path, dst_path) {
  html <- xml2::read_html(path(pkg$dst_path, dst_path), encoding = "UTF-8")
  img <- xml2::xml_find_all(html, ".//img")
  src <- xml2::xml_attr(img, "src")

  rel_src <- xml2::url_unescape(src[xml2::url_parse(src)$scheme == ""])
  rel_path <- path_norm(path(path_dir(dst_path), rel_src))
  exists <- file_exists(path(pkg$dst_path, rel_path))

  if (any(!exists)) {
    paths <- rel_src[!exists]
    cli::cli_inform(c(
      "Missing images in {.file {path_rel(src_path, pkg$src_path)}}: {.file {paths}}",
      i = "pkgdown can only use images in {.file man/figures} and {.file vignettes}"
    ))
  }

  alt <- xml2::xml_attr(img, "alt")
  if (anyNA(alt)) {
    problems <- src[is.na(alt)]
    problems[grepl("^data:image", problems)] <- "<base64 encoded image>"
    cli::cli_inform(c(
      x = "Missing alt-text in {.file {path_rel(src_path, pkg$src_path)}}",
      set_names(problems, "*"),
      i = "Learn more in {.vignette pkgdown::accessibility}."
    ))
  }
}
