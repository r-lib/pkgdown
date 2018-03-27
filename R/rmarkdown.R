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

  on.exit(Sys.setenv(BSTINPUTS = Sys.getenv("BSTINPUTS")), add = TRUE)
  Sys.setenv(BSTINPUTS = get_bstinputs(input_path))

  path <- callr::r_safe(
    function(...) rmarkdown::render(...),
    args = args,
    show = !quiet
  )

  if (identical(path_ext(path)[[1]], "html")) {
    update_html(path, tweak_rmarkdown_html, input_path = path_dir(input_path))
  }
  if (digest != file_digest(output_path)) {
    cat_line("Writing ", dst_path(output))
  }

  # Copy over images needed by the document
  if (copy_images) {
    ext <- rmarkdown::find_external_resources(input_path, "UTF-8")
    ext_path <- ext$path[ext$web]
    file_copy(
      path(path_dir(input_path), ext_path),
      path(path_dir(output_path), ext_path),
      overwrite = TRUE
    )
  }

  invisible(path)
}

#' Get BSTINPUTS for JSS articles (adapted from tools::texi2dvi)
#'
#' @noRd
get_bstinputs <- function(input_path) {
  Rbstinputs <- file.path(R.home("share"), "texmf", "bibtex", "bst")
  obstinputs <- Sys.getenv("BSTINPUTS", unset = NA_character_)
  if(is.na(obstinputs))
    obstinputs <- "."

  paste(obstinputs, dirname(input_path), Rbstinputs, sep = .Platform$path.sep)
}
