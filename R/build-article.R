#' @order 2
#' @export
#' @rdname build_articles
#' @param name Name of article to render. This should be either a path
#'   relative to `vignettes/` without extension, or `index` or `README`.
#' @param data Additional data to pass on to template.
#' @param new_process Build the article in a clean R process? The default,
#'   `TRUE`, ensures that every article is build in a fresh environment, but
#'   you may want to set it to `FALSE` to make debugging easier.
build_article <- function(name,
                          pkg = ".",
                          data = list(),
                          lazy = FALSE,
                          seed = 1014L,
                          new_process = TRUE,
                          quiet = TRUE) {

  pkg <- as_pkgdown(pkg)

  # Look up in pkg vignette data - this allows convenient automatic
  # specification of depth, output destination, and other parameters that
  # allow code sharing with building of the index.
  vig <- match(name, pkg$vignettes$name)
  if (is.na(vig)) {
    cli::cli_abort(
      "Can't find article {.file {name}}"
    )
  }

  input <- pkg$vignettes$file_in[vig]
  output_file <- pkg$vignettes$file_out[vig]
  depth <- pkg$vignettes$depth[vig]

  input_path <- path_abs(input, pkg$src_path)
  output_path <- path_abs(output_file, pkg$dst_path)

  if (lazy && !out_of_date(input_path, output_path)) {
    return(invisible())
  }

  local_envvar_pkgdown(pkg)
  local_options_link(pkg, depth = depth)

  front <- rmarkdown::yaml_front_matter(input_path)
  # Take opengraph from article's yaml front matter
  front_opengraph <- check_open_graph(pkg, front$opengraph, input)
  data$opengraph <- modify_list(data$opengraph, front_opengraph)

  # Allow users to opt-in to their own template
  ext <- purrr::pluck(front, "pkgdown", "extension", .default = "html")
  as_is <- isTRUE(purrr::pluck(front, "pkgdown", "as_is"))

  default_data <- list(
    pagetitle = escape_html(front$title),
    toc = front$toc %||% TRUE,
    opengraph = list(description = front$description %||% pkg$package),
    source = repo_source(pkg, input),
    filename = path_file(input),
    output_file = output_file,
    as_is = as_is
  )
  data <- modify_list(default_data, data)

  if (as_is) {
    format <- NULL

    if (identical(ext, "html")) {
      data$as_is <- TRUE
      template <- rmarkdown_template(pkg, "article", depth = depth, data = data)
      output <- rmarkdown::default_output_format(input_path)

      # Override defaults & values supplied in metadata
      options <- list(
        template = template$path,
        self_contained = FALSE
      )
      if (output$name != "rmarkdown::html_vignette") {
        # Force to NULL unless overridden by user
        options$theme <- output$options$theme
      }
    } else {
      options <- list()
    }
  } else {
    format <- build_rmarkdown_format(
      pkg = pkg,
      name = "article",
      depth = depth,
      data = data,
      toc = TRUE
    )
    options <- NULL
  }

  render_rmarkdown(
    pkg,
    input = input,
    output = output_file,
    output_format = format,
    output_options = options,
    seed = seed,
    new_process = new_process,
    quiet = quiet
  )
}

build_rmarkdown_format <- function(pkg,
                                   name,
                                   depth = 1L,
                                   data = list(),
                                   toc = TRUE) {

  template <- rmarkdown_template(pkg, name, depth = depth, data = data)

  out <- rmarkdown::html_document(
    toc = toc,
    toc_depth = 2,
    self_contained = FALSE,
    theme = NULL,
    template = template$path,
    anchor_sections = FALSE,
    math_method = config_math_rendering(pkg),
    extra_dependencies = bs_theme_deps_suppress()
  )
  out$knitr$opts_chunk <- fig_opts_chunk(pkg$figures, out$knitr$opts_chunk)

  old_pre <- out$pre_knit
  width <- config_pluck_number_whole(pkg, "code.width", default = 80)

  out$pre_knit <- function(...) {
    options(width = width)
    if (is.function(old_pre)) {
      old_pre(...)
    }
  }

  attr(out, "__cleanup") <- template$cleanup

  out
}

# Generates pandoc template format by rendering
# inst/template/article-vignette.html
# Output is a path + environment; when the environment is garbage collected
# the path will be deleted
rmarkdown_template <- function(pkg, name, data, depth) {
  path <- tempfile(fileext = ".html")
  render_page(pkg, name, data, path, depth = depth, quiet = TRUE)

  # Remove template file when format object is GC'd
  e <- env()
  reg.finalizer(e, function(e) file_delete(path))

  list(path = path, cleanup = e)
}

render_rmarkdown <- function(pkg,
                             input,
                             output,
                             ...,
                             seed = NULL,
                             copy_images = TRUE,
                             new_process = TRUE,
                             quiet = TRUE,
                             call = caller_env()) {

  input_path <- path_abs(input, pkg$src_path)
  output_path <- path_abs(output, pkg$dst_path)

  if (!file_exists(input_path)) {
    cli::cli_abort("Can't find {src_path(input)}.", call = call)
  }

  cli::cli_inform("Reading {src_path(input)}")
  digest <- file_digest(output_path)

  args <- list(
    input = input_path,
    output_file = path_file(output_path),
    output_dir = path_dir(output_path),
    intermediates_dir = tempdir(),
    encoding = "UTF-8",
    seed = seed,
    ...,
    quiet = quiet
  )

  withr::local_envvar(
    callr::rcmd_safe_env(),
    BSTINPUTS = bst_paths(input_path),
    TEXINPUTS = tex_paths(input_path),
    BIBINPUTS = bib_paths(input_path),
    R_CLI_NUM_COLORS = 256
  )

  if (new_process) {
    path <- withCallingHandlers(
      callr::r_safe(rmarkdown_render_with_seed, args = args, show = !quiet),
      error = function(cnd) {
        lines <- strsplit(gsub("^\r?\n", "", cnd$stderr), "\r?\n")[[1]]
        lines <- escape_cli(lines)
        cli::cli_abort(
          c(
            "!" = "Failed to render {.path {input}}.",
            set_names(lines, "x")
          ),
          parent = cnd$parent %||% cnd,
          trace = cnd$parent$trace,
          call = call
        )
      }
    )
  } else {
    path <- inject(rmarkdown_render_with_seed(!!!args))
  }

  is_html <- identical(path_ext(path)[[1]], "html")
  if (is_html) {
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
  if (copy_images && is_html) {
    ext_src <- rmarkdown::find_external_resources(input_path)

    # temporarily copy the rendered html into the input path directory and scan
    # again for additional external resources that may be been included by R code
    tempfile <- path(path_dir(input_path), "--find-assets.html")
    withr::defer(try(file_delete(tempfile)))
    file_copy(path, tempfile)
    ext_post <- rmarkdown::find_external_resources(tempfile)

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

  if (is_html) {
    check_missing_images(pkg, input_path, output)
  }

  invisible(path)
}

#' Escapes a cli msg
#'
#' Removes empty lines and escapes braces
#' @param msg A character vector with messages to be escaped
#' @noRd
escape_cli <- function(msg) {
  msg <- msg[nchar(msg) >0]
  msg <- gsub("{", "{{", msg, fixed = TRUE)
  msg <- gsub("}", "}}", msg, fixed = TRUE)
  msg
}

rmarkdown_render_with_seed <- function(..., seed = NULL) {
  if (!is.null(seed)) {
    set.seed(seed)
    if (requireNamespace("htmlwidgets", quietly = TRUE)) {
      htmlwidgets::setWidgetIdSeed(seed)
    }
  }

  # Ensure paths from output are not made relative to input
  # https://github.com/yihui/knitr/issues/2171
  options(knitr.graphics.rel_path = FALSE)

  rmarkdown::render(envir = globalenv(), ...)
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
