build_mds <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  if (refuses_mds(pkg)) {
    return()
  }

  url <- paste0(config_pluck_string(pkg, "url"), "/")
  if (is.null(url)) {
    return()
  }

  cli::cli_rule("Building Markdowns")
  if (pkg$development$in_dev && pkg$bs_version > 3) {
    url <- paste0(url, pkg$prefix)
  }

  paths <- get_site_paths(pkg)

  purrr::walk(paths, build_md, pkg = pkg)

  invisible()
}

refuses_mds <- function(pkg) {
  !config_pluck_bool(pkg, "template.build-md", default = TRUE)
}

build_md <- function(path, pkg) {
  rlang::check_installed("pandoc")
  path <- path(pkg[["dst_path"]], path)

  main_html <- xml2::read_html(path) |>
    xml2::xml_find_first(".//main")

  if (length(main_html) == 0) {
    return()
  }

  # uninformative image (logo) + source link
  title <- xml2::xml_find_first(main_html, ".//h1")
  xml2::xml_remove(
    xml2::xml_find_first(main_html, ".//div[@class='page-header']")
  )

  xml2::xml_add_child(
    main_html,
    title,
    .where = 0
  )

  # clean links
  xml2::xml_remove(
    xml2::xml_find_all(main_html, ".//a[@class='anchor']")
  )

  internal_links <- xml2::xml_find_all(
    main_html,
    ".//a[not(@class='external-link')]"
  )

  purrr::walk(
    internal_links,
    add_website_url,
    pkg = pkg,
    root = fs::path_rel(fs::path_dir(path), start = pkg$dst_path)
  )

  xml2::xml_set_attr(
    xml2::xml_find_all(main_html, ".//a[@class='external-link']"),
    attr = "class",
    value = NULL
  )

  pandoc::pandoc_convert(
    text = main_html,
    from = "html",
    to = "markdown_strict+definition_lists+footnotes+backtick_code_blocks",
    output = sprintf("%s.md", path)
  )

  readme_path <- path(pkg[["dst_path"]], "index.html.md")
  if (file_exists(readme_path)) {
    readme <- read_lines(readme_path) |>
      paste(collapse = "\n")
  } else {
    readme <- ""
  }

  reference_path <- path(pkg[["dst_path"]], "reference", "index.html.md")
  if (file_exists(reference_path)) {
    reference <- read_lines(reference_path) |>
      paste(collapse = "\n")
  } else {
    reference <- ""
  }

  article_path <- path(pkg[["dst_path"]], "articles", "index.html.md")
  if (file_exists(article_path)) {
    articles <- read_lines(article_path) |>
      paste(collapse = "\n")
  } else {
    articles <- ""
  }

  llms_lines <- whisker::whisker.render(
    read_file(find_template("summary", "llms", ext = ".txt", pkg = pkg)),
    data = list(
      readme = readme,
      reference = reference,
      articles = articles
    )
  )

  write_lines(llms_lines, path(pkg[["dst_path"]], "llms.txt"))
}

add_website_url <- function(node, pkg, root) {
  url <- sprintf("%s/", config_pluck_string(pkg, "url"))
  if (pkg$development$in_dev && pkg$bs_version > 3) {
    url <- paste0(url, pkg$prefix)
  }

  if (root != ".") {
    url <- sprintf("%s%s/", url, root)
  }

  xml2::xml_set_attr(
    node,
    attr = "href",
    value = sprintf("%s%s.md", url, xml2::xml_attr(node, "href"))
  )
}
