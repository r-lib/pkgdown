build_quarto_articles <- function(pkg = ".", quiet = TRUE) {
  check_required("quarto")
  pkg <- as_pkgdown(pkg)

  metadata_path <- withr::local_tempfile(
    fileext = ".yml",
    pattern = "pkgdown-quarto-metadata-"
  )
  metadata <- quarto_metadata(pkg)
  yaml::write_yaml(
    metadata,
    metadata_path,
    handlers = list(logical = yaml::verbatim_logical)
  )

  # Need to simulate a project so we can build entire directory
  project_path <- path(pkg$src_path, "vignettes", "_quarto.yaml")
  if (!file_exists(project_path)) {
    file_create(project_path)
    withr::defer(file_delete(project_path))
  }

  output_dir <- withr::local_tempdir("pkgdown-quarto-")
  quarto::quarto_render(
    path(pkg$src_path, "vignettes"),
    metadata_file = metadata_path,
    execute_dir = output_dir,
    quarto_args = c("--output-dir", output_dir),
    quiet = quiet,
    as_job = FALSE
  )
  
  htmls <- dir_ls(output_dir, glob = "*.html")
  out_path <- path("articles", path_rel(htmls, output_dir))
  data <- lapply(htmls, quarto_parse_rendered)

  purrr::walk2(data, out_path, function(data, path) {
    render_page(pkg, "quarto", data, path)
  })

  # Copy resources
  resources <- setdiff(dir_ls(output_dir, recurse = TRUE), htmls)
  resources <- resources[!is_dir(resources)]
  file_copy_to(
    src_paths = resources,
    dst_paths = path(pkg$dst_path, "articles", path_rel(resources, output_dir)),
    src_root = output_dir,
    dst_root = pkg$dst_path
  )

  invisible()
}

quarto_metadata <- function(pkg) {
  list(
    lang = pkg$lang,
    format = list(
      html = list(
        template = system_file("quarto", "template.html", package = "pkgdown"),
        minimal = TRUE,
        theme = "none",
        `highlight-style` = "none",
        `html-math-method` = config_math_rendering(pkg),
        `embed-resources` = FALSE,
        toc = FALSE # pkgdown generates with js
      )
    )
  )
}

quarto_parse_rendered <- function(path) { 
  html <- xml2::read_html(path, encoding = "UTF-8")
  meta_div <- xml2::xml_find_first(html, "//body/div[@class='meta']")

  list(
    pagetitle = escape_html(xpath_text(html, "//head/title")),
    toc = TRUE, 
    source = "???",
    includes = list(
      head = xml2str(xpath_xml(html, "//head/script|//head/link")),
      before = xpath_contents(html, "//body/div[@class='includes-before']"),
      after = xpath_contents(html, "//body/div[@class='includes-after']"),
      style = xpath_text(html, "//head/style")
    ),
    meta = list(
      title = xpath_contents(meta_div, "./h1"),
      subtitle = xpath_contents(meta_div, "./p[@class='subtitle']"),
      author = xpath_contents(meta_div, "./p[@class='author']"),
      date = xpath_contents(meta_div, "./p[@class='date']"),
      abstract = xpath_contents(meta_div, "./div[@class='abstract']")
    ),
    body = xpath_contents(html, "//main")
  )
}
