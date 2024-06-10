build_quarto_articles <- function(pkg = ".") {
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

  output_dir <- withr::local_tempdir("pkgdown-quarto-")

  project_path <- path(pkg$src_path, "vignettes", "_quarto.yaml")
  if (!file_exists(project_path)) {
    file_create(project_path)
    withr::defer(file_delete(project_path))
  }

  output_dir <- "~/Desktop/test"
  quarto::quarto_render(
    path(pkg$src_path, "vignettes"),
    metadata_file = metadata_path,
    # quarto_args = c("--output-dir", output_dir),
    as_job = FALSE
  )

  qmds <- dir_ls(path(pkg$src_path, "vignettes"), glob = "*.qmd")
  htmls <- path_ext_set(qmds, "html")
  parsed <- lapply(htmls, quarto_parse_rendered)

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
  html <- xml2::read_html(path)

  meta_div <- xml2::xml_find_first(html, "//body/div[@class='meta']")

  list(
    pagetitle = xpath_text(html, "//head/title"),
    includes = list(
      head = as.character(xpath_xml(html, "//head/script|//meta/link")),
      before = xpath_contents(html, "//body/div[@class='includes-before']"),
      after = xpath_contents(html, "//body/div[@class='includes-after']"),
      style = xpath_text(html, "//head/style")
    ),
    meta = list(
      title = xpath_content(meta_div, "./h1"),
      subtitle = xpath_contents(meta_div, "./p[@class='subtitle']"),
      author = xpath_contents(meta_div, "./p[@class='author']"),
      date = xpath_contents(meta_div, "./p[@class='date']"),
      abstract = xpath_contents(meta_div, "./div[@class='abstract']")
    ),
    body = xpath_contents(html, "//main")
  )
}
