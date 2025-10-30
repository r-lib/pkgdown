#' @order 2
#' @export
#' @rdname build_articles
#' @param name Name of article to render. This should be either a path
#'   relative to `vignettes/` *without extension*, or `index` or `README`.
#' @param new_process Build the article in a clean R process? The default,
#'   `TRUE`, ensures that every article is build in a fresh environment, but
#'   you may want to set it to `FALSE` to make debugging easier.
#' @param pandoc_args Pass additional arguments to pandoc. Used for testing.
build_article <- function(
  name,
  pkg = ".",
  lazy = FALSE,
  seed = 1014L,
  new_process = TRUE,
  pandoc_args = character(),
  override = list(),
  quiet = TRUE
) {
  pkg <- section_init(pkg, "articles", override = override)

  # Look up in pkg vignette data - this allows convenient automatic
  # specification of depth, output destination, and other parameters that
  # allow code sharing with building of the index.
  vig <- match(name, pkg$vignettes$name)
  if (is.na(vig)) {
    cli::cli_abort("Can't find article {.file {name}}")
  }

  input <- pkg$vignettes$file_in[vig]
  output_file <- pkg$vignettes$file_out[vig]
  depth <- pkg$vignettes$depth[vig]
  type <- pkg$vignettes$type[vig]

  input_path <- path_abs(input, pkg$src_path)
  output_path <- path_abs(output_file, pkg$dst_path)

  if (lazy && !out_of_date(input_path, output_path)) {
    return(invisible())
  }

  if (type == "rmd") {
    build_rmarkdown_article(
      pkg = pkg,
      input_file = input,
      input_path = input_path,
      output_file = output_file,
      output_path = output_path,
      depth = depth,
      seed = seed,
      new_process = new_process,
      pandoc_args = pandoc_args,
      quiet = quiet
    )
  } else {
    build_quarto_articles(pkg = pkg, article = name, quiet = quiet)
  }
}

build_rmarkdown_article <- function(
  pkg,
  input_file,
  input_path,
  output_file,
  output_path,
  depth,
  seed = NULL,
  new_process = TRUE,
  pandoc_args = character(),
  quiet = TRUE,
  call = caller_env()
) {
  cli::cli_inform("Reading {src_path(input_file)}")
  digest <- file_digest(output_path)

  data <- data_article(pkg, input_file, call = call)
  if (data$as_is) {
    if (identical(data$ext, "html")) {
      setup <- rmarkdown_setup_custom(
        pkg,
        input_path,
        depth = depth,
        data = data
      )
    } else {
      setup <- list(format = NULL, options = NULL)
    }
  } else {
    setup <- rmarkdown_setup_pkgdown(
      pkg,
      depth = depth,
      data = data,
      pandoc_args = pandoc_args
    )
  }

  local_envvar_pkgdown(pkg)
  local_texi2dvi_envvars(input_path)
  withr::local_envvar(R_CLI_NUM_COLORS = 256)

  args <- list(
    input = input_path,
    output_file = path_file(output_path),
    output_dir = path_dir(output_path),
    intermediates_dir = tempdir(),
    encoding = "UTF-8",
    seed = seed,
    output_format = setup$format,
    output_options = setup$options,
    quiet = quiet
  )
  if (new_process) {
    path <- withCallingHandlers(
      callr::r_safe(rmarkdown_render_with_seed, args = args, show = !quiet),
      error = function(cnd) wrap_rmarkdown_error(cnd, input_file, call)
    )
  } else {
    path <- inject(rmarkdown_render_with_seed(!!!args))
  }

  is_html <- identical(path_ext(path)[[1]], "html")
  if (is_html) {
    local_options_link(pkg, depth = depth)
    update_html(
      path,
      tweak_rmarkdown_html,
      input_path = path_dir(input_path),
      pkg = pkg
    )
    # Need re-active navbar now that we now the target path
    update_html(path, function(html) {
      activate_navbar(html, path_rel(path, pkg$dst_path), pkg)
    })
  }
  if (digest != file_digest(output_path)) {
    writing_file(path_rel(output_path, pkg$dst_path), output_file)
  }
  if (is_html) {
    copy_article_images(path, input_path, output_path)
    check_missing_images(pkg, input_path, output_file)
  }

  invisible(path)
}


data_article <- function(pkg, input, call = caller_env()) {
  yaml <- rmarkdown::yaml_front_matter(path_abs(input, pkg$src_path))

  opengraph <- check_open_graph(pkg, yaml$opengraph, input, call = call)
  opengraph$description <- opengraph$description %||% yaml$description

  list(
    opengraph = opengraph,
    pagetitle = escape_html(yaml$title),
    toc = yaml$toc %||% TRUE,
    source = repo_source(pkg, input),
    filename = path_file(input),
    as_is = isTRUE(purrr::pluck(yaml, "pkgdown", "as_is")),
    ext = purrr::pluck(yaml, "pkgdown", "extension", .default = "html")
  )
}

rmarkdown_setup_custom <- function(
  pkg,
  input_path,
  depth = 1L,
  data = list(),
  env = caller_env()
) {
  template <- rmarkdown_template(pkg, depth = depth, data = data, env = env)

  # Override defaults & values supplied in metadata
  options <- list(
    template = template,
    self_contained = FALSE
  )

  output <- rmarkdown::default_output_format(input_path)
  if (output$name != "rmarkdown::html_vignette") {
    # Force to NULL unless overridden by user
    options$theme <- output$options$theme
  }

  list(format = NULL, options = options)
}

rmarkdown_setup_pkgdown <- function(
  pkg,
  depth = 1L,
  data = list(),
  pandoc_args = character(),
  env = caller_env()
) {
  template <- rmarkdown_template(pkg, depth = depth, data = data, env = env)

  format <- rmarkdown::html_document(
    self_contained = FALSE,
    theme = NULL,
    template = template,
    anchor_sections = FALSE,
    math_method = config_math_rendering(pkg),
    extra_dependencies = bs_theme_deps_suppress(),
    pandoc_args = pandoc_args
  )
  format$knitr$opts_chunk <- fig_opts_chunk(
    pkg$figures,
    format$knitr$opts_chunk
  )

  # Add knitr hook to inject CSS class into plot img tags
  format$knitr$knit_hooks <- format$knitr$knit_hooks %||% list()
  format$knitr$knit_hooks$plot <- function(x, options) {
    # Get the default plot hook output
    hook_output <- knitr::hook_plot_md(x, options)

    # Add the fig.class to img tags if specified
    if (!is.null(options$fig.class)) {
      # Match img tags and add class attribute
      hook_output <- gsub(
        '<img src="([^"]+)"',
        sprintf('<img src="\\1" class="%s"', options$fig.class),
        hook_output
      )
    }

    hook_output
  }

  width <- config_pluck_number_whole(pkg, "code.width", default = 80)
  old_pre <- format$pre_knit
  format$pre_knit <- function(...) {
    options(width = width)
    if (is.function(old_pre)) {
      old_pre(...)
    }
  }

  list(format = format, options = NULL)
}

# Generates pandoc template by rendering templates/content-article.html
rmarkdown_template <- function(
  pkg,
  data = list(),
  depth = 1L,
  env = caller_env()
) {
  path <- withr::local_tempfile(
    pattern = "pkgdown-rmd-template-",
    fileext = ".html",
    .local_envir = env
  )
  render_page(pkg, "article", data, path, depth = depth, quiet = TRUE)

  path
}

copy_article_images <- function(built_path, input_path, output_path) {
  ext_src <- rmarkdown::find_external_resources(input_path)

  # temporarily copy the rendered html into the input path directory and scan
  # again for additional external resources that may be been included by R code
  tempfile <- path(path_dir(input_path), "--find-assets.html")
  withr::defer(try(file_delete(tempfile)))
  file_copy(built_path, tempfile)
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

wrap_rmarkdown_error <- function(cnd, input, call = caller_env()) {
  lines <- strsplit(gsub("^\r?\n", "", cnd$stderr), "\r?\n")[[1]]
  lines <- lines[nchar(lines) > 0]
  # Feeding random text back into cli, so have to escape
  lines <- gsub("{", "{{", lines, fixed = TRUE)
  lines <- gsub("}", "}}", lines, fixed = TRUE)

  cli::cli_abort(
    c(
      "!" = "Failed to render {.path {input}}.",
      set_names(cli_escape(lines), "x")
    ),
    parent = cnd$parent %||% cnd,
    trace = cnd$parent$trace,
    call = call
  )
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
