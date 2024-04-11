#' Render RMarkdown document in a fresh session
#'
#' @noRd
render_rmarkdown <- function(pkg, input, output, ..., seed = NULL, copy_images = TRUE, quiet = TRUE) {

  input_path <- path_abs(input, pkg$src_path)
  output_path <- path_abs(output, pkg$dst_path)

  if (!file_exists(input_path)) {
    cli::cli_abort("Can't find {src_path(input).", call = caller_env())
  }

  cli::cli_inform("Reading {src_path(input)}")
  digest <- file_digest(output_path)

  args <- list(
    input = input_path,
    output_file = path_file(output_path),
    output_dir = path_dir(output_path),
    intermediates_dir = tempdir(),
    encoding = "UTF-8",
    envir = globalenv(),
    seed = seed,
    ...,
    quiet = quiet
  )

  path <- tryCatch(
    callr::r_safe(
      function(seed, envir, ...) {
        if (!is.null(seed)) {
          # since envir is copied from the parent fn into callr::r_safe(),
          # set.seed() sets the seed in the wrong global env and we have to
          # manually copy it over
          set.seed(seed)
          envir$.Random.seed <- .GlobalEnv$.Random.seed
          if (requireNamespace("htmlwidgets", quietly = TRUE)) {
            htmlwidgets::setWidgetIdSeed(seed)
          }
        }
        rmarkdown::render(envir = envir, ...)
      },
      args = args,
      show = !quiet,
      env = c(
        callr::rcmd_safe_env(),
        BSTINPUTS = bst_paths(input_path),
        TEXINPUTS = tex_paths(input_path),
        BIBINPUTS = bib_paths(input_path),
        R_CLI_NUM_COLORS = 256
      )
    ),
    error = function(cnd) {
      cli::cli_abort(
        c(
          "Failed to render RMarkdown document.",
          x = gsub("\r", "", cnd$stderr, fixed = TRUE)
        ),
        parent = cnd
      )
    }
  )

  if (identical(path_ext(path)[[1]], "html")) {
    update_html(
      path,
      tweak_rmarkdown_html,
      input_path = path_dir(input_path),
      pkg = pkg
    )
  }
  if (digest != file_digest(output_path)) {
    writing_file(path_rel(output_path, pkg$dst_path), output)
  }

  # Copy over images needed by the document
  if (copy_images) {
    ext_src <- rmarkdown::find_external_resources(input_path)

    # temporarily copy the rendered html into the input path directory and scan
    # again for additional external resources that may be been included by R code
    tempfile_in_input_dir <- file_temp(ext = "html", tmp_dir = path_dir(input_path))
    file_copy(path, tempfile_in_input_dir)
    withr::defer(unlink(tempfile_in_input_dir))
    ext_post <- rmarkdown::find_external_resources(tempfile_in_input_dir)

    ext <- rbind(ext_src, ext_post)
    ext <- ext[!duplicated(ext$path), ]

    # copy web + explicit files beneath vignettes/
    is_child <- path_has_parent(ext$path, ".")
    ext_path <- ext$path[(ext$web | ext$explicit) & is_child]

    src <- path(path_dir(input_path), ext_path)
    dst <- path(path_dir(output_path), ext_path)
    # Make sure destination paths exist before copying files there
    dir_create(unique(path_dir(dst)))
    file_copy(src, dst, overwrite = TRUE)
  }
  check_missing_images(pkg, input, output)

  invisible(path)
}

# adapted from tools::texi2dvi
bst_paths <- function(path) {
  paths <- c(
    Sys.getenv("BSTINPUTS"),
    path_dir(path),
    path(R.home("share"), "texmf", "bibtex", "bst")
  )
  paste(paths, collapse = .Platform$path.sep)
}
tex_paths <- function(path) {
  paths <- c(
    Sys.getenv("TEXINPUTS"),
    path_dir(path),
    path(R.home("share"), "texmf", "tex", "latex")
  )
  paste(paths, collapse = .Platform$path.sep)
}
bib_paths <- function(path) {
  paths <- c(
    Sys.getenv("BIBINPUTS"),
    tex_paths(path)
  )
  paste(paths, collapse = .Platform$path.sep)

}
