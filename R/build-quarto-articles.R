build_quarto_articles <- function(pkg = ".", article = NULL, quiet = TRUE) {
  pkg <- as_pkgdown(pkg)

  qmds <- pkg$vignettes[pkg$vignettes$type == "qmd", ]
  if (!is.null(article)) {
    qmds <- qmds[qmds$name == article, ]
  }
  if (nrow(qmds) == 0) {
    return()
  }
  if (pkg$bs_version < 5) {
    cli::cli_abort(
      c(
        "Quarto articles require Bootstrap 5.",
        "i" = "See details at {.url https://pkgdown.r-lib.org/articles/customise.html#getting-started}"
      ),
      call = NULL
    )
  }
  check_installed("quarto")
  if (quarto::quarto_version() < "1.5") {
    cli::cli_abort(
      "Quarto articles require version 1.5 and above.",
      call = NULL
    )
  }
  # Let user know what's happening
  old_digest <- purrr::map_chr(path(pkg$dst_path, qmds$file_out), file_digest)
  for (file in qmds$file_in) {
    cli::cli_inform("Reading {src_path(file)}")
  }
  cli::cli_inform("Running {.code quarto render}")

  # If needed, temporarily make a quarto project so we can build entire dir
  if (is.null(article)) {
    project_path <- path(pkg$src_path, "vignettes", "_quarto.yaml")
    if (!file_exists(project_path)) {
      yaml::write_yaml(
        list(project = list(render = list("*.qmd"))),
        project_path
      )
      withr::defer(file_delete(project_path))
    }
  }

  if (is.null(article)) {
    src_path <- path(pkg$src_path, "vignettes")
  } else {
    src_path <- path(pkg$src_path, qmds$file_in)
  }
  output_dir <- quarto_render(pkg, src_path, quiet = quiet)

  # check for articles (in the `vignette/articles` sense)
  article_dir <- fs::path(output_dir, "articles")
  if (fs::dir_exists(article_dir)) {
    fs::file_move(dir_ls(article_dir), output_dir)
  }

  # Read generated data from quarto template and render into pkgdown template
  unwrap_purrr_error(purrr::walk2(
    qmds$file_in,
    qmds$file_out,
    function(input_file, output_file) {
      built_path <- path(output_dir, path_rel(output_file, "articles"))
      if (!file_exists(built_path)) {
        cli::cli_abort("No built file found for {.file {input_file}}")
      }
      if (path_ext(output_file) == "html") {
        data <- data_quarto_article(pkg, built_path, input_file)
        render_page(pkg, "quarto", data, output_file, quiet = TRUE)

        update_html(path(pkg$dst_path, output_file), tweak_quarto_html)
      } else {
        file_copy(built_path, path(pkg$dst_path, output_file), overwrite = TRUE)
      }
    }
  ))

  # Report on which files have changed
  new_digest <- purrr::map_chr(path(pkg$dst_path, qmds$file_out), file_digest)
  changed <- new_digest != old_digest
  for (file in qmds$file_out[changed]) {
    writing_file(path(pkg$dst_path, file), file)
  }

  # Copy resources
  resources <- setdiff(
    dir_ls(output_dir, recurse = TRUE, type = "file"),
    path(output_dir, path_rel(qmds$file_out, "articles"))
  )
  file_copy_to(
    src_paths = resources,
    dst_paths = path(pkg$dst_path, "articles", path_rel(resources, output_dir)),
    src_root = output_dir,
    dst_root = pkg$dst_path,
    src_label = NULL
  )

  invisible()
}

quarto_render <- function(pkg, path, quiet = TRUE, frame = caller_env()) {
  # Override default quarto format
  metadata_path <- withr::local_tempfile(
    fileext = ".yml",
    pattern = "pkgdown-quarto-metadata-",
  )
  write_yaml(quarto_format(pkg), metadata_path)

  output_dir <- withr::local_tempdir("pkgdown-quarto-", .local_envir = frame)

  quarto::quarto_render(
    path,
    metadata_file = metadata_path,
    execute_dir = output_dir,
    quarto_args = c("--output-dir", output_dir),
    quiet = quiet,
    as_job = FALSE
  )

  output_dir
}

quarto_format <- function(pkg) {
  list(
    lang = pkg$lang,
    format = list(
      html = list(
        template = system_file("quarto", "template.html", package = "pkgdown"),
        minimal = TRUE,
        theme = "none",
        `html-math-method` = config_math_rendering(pkg),
        `embed-resources` = FALSE,
        `citations-hover` = TRUE,
        `link-citations` = TRUE,
        `section-divs` = TRUE,
        toc = FALSE # pkgdown generates with js
      )
    )
  )
}

data_quarto_article <- function(pkg, path, input_path) {
  html <- xml2::read_html(path, encoding = "UTF-8")
  meta_div <- xml2::xml_find_first(html, "//body/div[@class='meta']")

  # Manually drop any jquery deps
  head <- xpath_xml(html, "//head/script|//head/link")
  head <- head[!grepl("jquery", xml2::xml_attr(head, "src"))]

  list(
    pagetitle = escape_html(xpath_text(html, "//head/title")),
    toc = TRUE,
    source = repo_source(pkg, input_path),
    includes = list(
      head = xml2str(head),
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

tweak_quarto_html <- function(html) {
  # If top-level headings use h1, move everything down one level
  h1 <- xml2::xml_find_all(html, "//h1")
  if (length(h1) > 1) {
    tweak_section_levels(html)
  }
}
