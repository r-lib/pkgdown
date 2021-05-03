build_redirects <- function(pkg = ".",
                            override = list()) {
  pkg <- section_init(pkg, depth = 1L, override = override)

  if (is.null(pkg$meta$redirects)) {
    return(invisible())
  }

  rule("Building redirects")
  if (is.null(pkg$meta$url)) {
    abort(sprintf("Can't find %s.", pkgdown_field(pkg, "url")))
  }

  sitemap <- xml2::read_xml(file.path(pkg$dst_path, "sitemap.xml"))
  paths <- xml2::xml_contents(sitemap) %>%
    purrr::map_chr(xml2::xml_text) %>%
    get_url_paths()

  purrr::walk(
    pkg$meta$redirects,
    build_redirect,
    pkg = pkg,
    paths = paths
  )
}

build_redirect <- function(entry, pkg, paths) {
  new <- entry[2]
  old <- entry[1]

  path <- find_template(
    "content", "redirect",
    template_path = template_path(pkg),
    bs_version = pkg$bs_version
  )
  template <- read_file(path)

  url <- sprintf("%s/%s%s", pkg$meta$url, pkg$prefix, new)
  lines <- whisker::whisker.render(template, list(url = url))
  write_lines(lines, file.path(pkg$dst_path, old))
}

get_url_paths <- function(urls) {
  purrr::map_chr(urls, function(x) httr::parse_url(x)$path)
}
