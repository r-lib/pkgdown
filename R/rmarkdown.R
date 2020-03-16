#' Render RMarkdown document in a fresh session
#'
#' @noRd
render_rmarkdown <- function(pkg, input, output, ..., copy_images = TRUE, quiet = TRUE) {

  input_path <- path_abs(input, pkg$src_path)
  output_path <- path_abs(output, pkg$dst_path)

  if (!file_exists(input_path)) {
    stop("Can't find ", src_path(input), call. = FALSE)
  }

  cat_line("Reading ", src_path(input))
  digest <- file_digest(output_path)

  args <- list(
    input = input_path,
    output_file = path_file(output_path),
    output_dir = path_dir(output_path),
    intermediates_dir = tempdir(),
    encoding = "UTF-8",
    envir = globalenv(),
    ...,
    quiet = quiet
  )

  path <- tryCatch(
    callr::r_safe(
      function(...) rmarkdown::render(...),
      args = args,
      show = !quiet,
      env = c(
        callr::rcmd_safe_env(),
        BSTINPUTS = bst_paths(input_path),
        TEXINPUTS = tex_paths(input_path),
        BIBINPUTS = bib_paths(input_path)
      )
    ),
    error = function(cnd) {
      abort(
        c("Failed to render RMarkdown", strsplit(cnd$stderr, "\r?\n")[[1]]),
        parent = cnd
      )
    }
  )

  if (identical(path_ext(path)[[1]], "html")) {
    update_html(path, tweak_rmarkdown_html, input_path = path_dir(input_path))
  }
  if (digest != file_digest(output_path)) {
    cat_line("Writing ", dst_path(output))
  }

  # Copy over images needed by the document
  if (copy_images) {
    ext <- rmarkdown::find_external_resources(input_path)
    ext_path <- ext$path[ext$web | ext$explicit]
    src <- path(path_dir(input_path), ext_path)
    dst <- path(path_dir(output_path), ext_path)
    # Make sure destination paths exist before copying files there
    dir_create(unique(path_dir(dst)))
    file_copy(src, dst, overwrite = TRUE)
  }

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
