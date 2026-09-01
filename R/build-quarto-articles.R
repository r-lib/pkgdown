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

        update_html(
          path(pkg$dst_path, output_file),
          tweak_quarto_html,
          qmd_path = path(pkg$src_path, input_file)
        )
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

tweak_quarto_html <- function(html, qmd_path = NULL) {
  # If top-level headings use h1, move everything down one level
  h1 <- xml2::xml_find_all(html, "//h1")
  if (length(h1) > 1) {
    tweak_section_levels(html)
  }

  tweak_quarto_callouts(html, qmd_path = qmd_path)
}

# pkgdown renders `.qmd` articles with `theme: "none"` and `minimal: TRUE`
# (see `quarto_format()`), which strips the CSS Quarto callouts rely on.
# Under those settings, Quarto's callout Lua filter falls back to a plain,
# class-less blockquote:
#
#   <div>
#   <blockquote>
#   <p><strong>Note</strong></p>
#   <p>Hello note</p>
#   </blockquote>
#   </div>
#
# This finds that pattern and rewrites it into Quarto's native callout markup
# (div.callout.callout-style-default.callout-<type>), so it can be styled by
# pkgdown's own CSS. A hand-written blockquote is never wrapped in a bare
# `<div>` by Pandoc, so this signature does not collide.
#
# A custom title is lost. If `qmd_path` is supplied we reconstruct the title
# from the original `.qmd`.
tweak_quarto_callouts <- function(html, qmd_path = NULL) {
  divs <- xml2::xml_find_all(html, "//div[not(@*)]")
  candidates <- list()
  for (div in divs) {
    children <- xml2::xml_children(div)
    if (length(children) != 1 || xml2::xml_name(children) != "blockquote") {
      next
    }
    bq_children <- xml2::xml_children(children)
    if (length(bq_children) < 1 || xml2::xml_name(bq_children[[1]]) != "p") {
      next
    }
    first_p <- bq_children[[1]]
    if (length(xml2::xml_children(first_p)) != 1) {
      next
    }
    strong <- xml2::xml_find_first(first_p, "./strong")
    if (is.na(xml2::xml_name(strong))) {
      next
    }
    candidates[[length(candidates) + 1L]] <- list(
      div = div,
      strong = strong,
      bq_children = bq_children
    )
  }

  if (length(candidates) == 0) {
    return(invisible())
  }

  source_types <- if (!is.null(qmd_path) && file_exists(qmd_path)) {
    callout_types_from_qmd(qmd_path)
  } else {
    character()
  }
  use_source_types <- length(source_types) == length(candidates)

  for (i in seq_along(candidates)) {
    cand <- candidates[[i]]
    known_type <- if (use_source_types) source_types[[i]] else NA_character_
    xml2::xml_replace(
      cand$div,
      quarto_callout_node(cand$strong, cand$bq_children, known_type)
    )
  }

  invisible()
}

quarto_callout_types <- c("note", "tip", "warning", "caution", "important")

callout_types_from_qmd <- function(qmd_path) {
  lines <- paste(read_lines(qmd_path), collapse = "\n")
  pattern <- ":::+\\s*\\{[^}]*\\.callout-(note|tip|warning|caution|important)[^}]*\\}"
  full <- regmatches(lines, gregexpr(pattern, lines, perl = TRUE))[[1]]
  sub(".*\\.callout-(note|tip|warning|caution|important).*", "\\1", full)
}

quarto_callout_node <- function(
  strong,
  bq_children,
  known_type = NA_character_
) {
  title <- trimws(xml2::xml_text(strong))
  type <- if (!is.na(known_type) && known_type %in% quarto_callout_types) {
    known_type
  } else {
    guess <- tolower(title)
    if (guess %in% quarto_callout_types) guess else "note"
  }

  body_nodes <- bq_children[-1]
  body_html <- paste(
    vapply(body_nodes, as.character, character(1)),
    collapse = "\n"
  )

  callout_html <- sprintf(
    '<div class="callout callout-style-default callout-%s callout-titled">
<div class="callout-header d-flex align-content-center">
<div class="callout-icon-container"><i class="callout-icon"></i></div>
<div class="callout-title-container flex-fill">%s</div>
</div>
<div class="callout-body-container callout-body">
%s
</div>
</div>',
    type,
    title,
    body_html
  )

  frag <- xml2::read_html(paste0(
    "<html><body>",
    callout_html,
    "</body></html>"
  ))
  xml2::xml_find_first(frag, "//body/div")
}
