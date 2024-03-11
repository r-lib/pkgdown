#' Build reference section
#'
#' By default, pkgdown will generate an index that lists all functions in
#' alphabetical order. To override this, provide a `reference` section in your
#' `_pkgdown.yml` as described below.
#'
#' @section Reference index:
#' To tweak the index page, add a section called `reference` to `_pkgdown.yml`.
#' It can contain three different types of element:
#'
#' * A **title** (`title` + `desc`), which generates an row containing an `<h2>`
#'   with optional paragraph description.
#' * A **subtitle** (`subtitle` + `desc`), which generates an row containing an
#'   `<h3>` with optional paragraph description.
#' * A **list of topics** (`contents`), which generates one row for each topic,
#'   with a list of aliases for the topic on the left, and the topic title
#'   on the right.
#'
#' (For historical reasons you can include `contents` with a title or
#' subtitle, but this is no longer recommended).
#'
#' Most packages will only need to use `title` and `contents` components.
#' For example, here's a snippet from the YAML that pkgdown uses to generate
#' its own reference index:
#'
#' ```yaml
#' reference:
#' - title: Build
#'   desc:  Build a complete site or its individual section components.
#' - contents:
#'   - starts_with("build_")
#' - title: Templates
#' - contents:
#'   - template_navbar
#'   - render_page
#' ```
#'
#' Bigger packages, e.g. ggplot2, may need an additional layer of
#' structure in order to clearly organise large number of functions:
#'
#' ```yaml
#' reference:
#' - title: Layers
#' - subtitle: Geoms
#'   desc: Geom is short for geometric element
#' - contents:
#'   - starts_with("geom")
#' - subtitle: Stats
#'   desc: Statistical transformations transform data before display.
#'   contents:
#'   - starts_with("stat")
#' ```
#'
#' `desc` can use markdown, and if you have a long description it's a good
#' idea to take advantage of the YAML `>` notation:
#'
#' ```yaml
#' desc: >
#'   This is a very _long_ and **overly** flowery description of a
#'   single simple function. By using `>`, it's easy to write a description
#'   that runs over multiple lines.
#' ```
#'
#' ## Topic matching
#' `contents` can contain:
#'
#' * Individual function/topic names.
#' * Weirdly named functions with doubled quoting, once for YAML and once for
#'   R, e.g. `` "`+.gg`" ``.
#' * `starts_with("prefix")` to select all functions with common prefix.
#' * `ends_with("suffix")` to select all functions with common suffix.
#' * `matches("regexp")` for more complex regular expressions.
#' * `has_keyword("x")` to select all topics with keyword "x";
#'   `has_keyword("datasets")` selects all data documentation.
#' * `has_concept("blah")` to select all topics with concept "blah".
#'   If you are using roxygen2, `has_concept()` also matches family tags, because
#'   roxygen2 converts them to concept tags.
#' * `lacks_concepts(c("concept1", "concept2"))` to select all topics
#'    without those concepts. This is useful to capture topics not otherwise
#'    captured by `has_concepts()`.
#' * Topics from other installed packages, e.g. `rlang::is_installed()` (function name)
#'  or `sass::font_face` (topic name).
#'
#' All functions (except for `has_keywords()`) automatically exclude internal
#' topics (i.e. those with `\keyword{internal}`). You can choose to include
#' with (e.g.) `starts_with("build_", internal = TRUE)`.
#'
#' Use a leading `-` to remove topics from a section, e.g. `-topic_name`,
#' `-starts_with("foo")`.
#'
#' pkgdown will check that all non-internal topics are included on
#' the reference index page, and error if you have missed any.
#'
#' ## Missing topics
#'
#' pkgdown will warn if there are (non-internal) topics that not listed
#' in the reference index. You can suppress these warnings by listing the
#' topics in section with "title: internal" (case sensitive) which will not be
#' displayed on the reference index.
#'
#' ## Icons
#' You can optionally supply an icon for each help topic. To do so, you'll need
#' a top-level `icons` directory. This should contain {.png} files that are
#' either 30x30 (for regular display) or 60x60 (if you want retina display).
#' Icons are matched to topics by aliases.
#'
#' ## Examples
#'
#' If you need to run extra code before or after all examples are run, you
#' can create `pkgdown/pre-reference.R` and `pkgdown/post-reference.R`.
#'
#' @section Figures:
#'
#' You can control the default rendering of figures by specifying the `figures`
#' field in `_pkgdown.yml`. The default settings are equivalent to:
#'
#' ```yaml
#' figures:
#'   dev: ragg::agg_png
#'   dpi: 96
#'   dev.args: []
#'   fig.ext: png
#'   fig.width: 7.2916667
#'   fig.height: ~
#'   fig.retina: 2
#'   fig.asp: 1.618
#'   bg: NA
#'   other.parameters: []
#' ```
#'
#' Most of these parameters are interpreted similarly to knitr chunk
#' options. `other.parameters` is a list of parameters
#' that will be available to custom graphics output devices such
#' as HTML widgets.
#'
#' @inheritParams build_articles
#' @param lazy If `TRUE`, only rebuild pages where the `.Rd`
#'   is more recent than the `.html`. This makes it much easier to
#'   rapidly prototype. It is set to `FALSE` by [build_site()].
#' @param run_dont_run Run examples that are surrounded in \\dontrun?
#' @param examples Run examples?
#' @param seed Seed used to initialize random number generation so that
#'   examples are reproducible.
#' @param devel Determines how code is loaded in order to run examples.
#'   If `TRUE` (the default), assumes you are in a live development
#'   environment, and loads source package with [pkgload::load_all()].
#'   If `FALSE`, uses the installed version of the package.
#' @param document **Deprecated** Use `devel` instead.
#' @param topics Build only specified topics. If supplied, sets `lazy`
#'   and `preview` to `FALSE`.
#' @export
build_reference <- function(pkg = ".",
                            lazy = TRUE,
                            examples = TRUE,
                            run_dont_run = FALSE,
                            seed = 1014,
                            override = list(),
                            preview = NA,
                            devel = TRUE,
                            document = "DEPRECATED",
                            topics = NULL) {
  pkg <- section_init(pkg, depth = 1L, override = override)

  if (document != "DEPRECATED") {
    lifecycle::deprecate_warn(
      "1.4.0",
      "build_site(document)",
      details = "build_site(devel)"
    )
    devel <- document
  }

  cli::cli_rule("Building function reference")
  build_reference_index(pkg)

  copy_figures(pkg)

  if (examples) {
    examples_env <- examples_env(pkg, seed = seed, devel = devel)
  } else {
    examples_env <- NULL
  }

  if (!is.null(topics)) {
    topics <- purrr::transpose(pkg$topics[pkg$topics$name %in% topics, ])
    lazy <- FALSE
    preview <- FALSE
  } else {
    topics <- purrr::transpose(pkg$topics)
  }

  purrr::map(
    topics,
    build_reference_topic,
    pkg = pkg,
    lazy = lazy,
    examples_env = examples_env,
    run_dont_run = run_dont_run
  )

  preview_site(pkg, "reference", preview = preview)
}

copy_figures <- function(pkg) {
  # copy everything from man/figures to docs/reference/figures
  src_figures <- path(pkg$src_path, "man", "figures")
  dst_figures <- path(pkg$dst_path, "reference", "figures")
  if (file_exists(src_figures)) {
    dir_copy_to(pkg, src_figures, dst_figures)
  }
}

examples_env <- function(pkg, seed = 1014, devel = TRUE, envir = parent.frame()) {
  # Re-loading pkgdown while it's running causes weird behaviour with
  # the context cache
  if (isTRUE(devel) && !(pkg$package %in% c("pkgdown", "rprojroot"))) {
    check_installed("pkgload", "to use `build_reference(devel = TRUE)`")
    pkgload::load_all(pkg$src_path, export_all = FALSE, helpers = FALSE, quiet = TRUE)
  } else {
    library(pkg$package, character.only = TRUE)
  }

  # Need to compute before changing working directory
  pre_path <- path_abs(path(pkg$src_path, "pkgdown", "pre-reference.R"))
  post_path <- path_abs(path(pkg$src_path, "pkgdown", "post-reference.R"))

  withr::local_dir(path(pkg$dst_path, "reference"), .local_envir = envir)
  width <- purrr::pluck(pkg, "meta", "code", "width", .default = 80)
  withr::local_options(width = width, .local_envir = envir)
  withr::local_seed(seed, .local_envir = envir)
  if (requireNamespace("htmlwidgets", quietly = TRUE)) {
    htmlwidgets::setWidgetIdSeed(seed)
  }

  examples_env <- child_env(globalenv())
  if (file_exists(pre_path)) {
    sys.source(pre_path, envir = examples_env)
  }
  if (file_exists(post_path)) {
    withr::defer(sys.source(post_path, envir = examples_env), envir = envir)
  }

  examples_env
}

#' @export
#' @rdname build_reference
build_reference_index <- function(pkg = ".") {
  pkg <- section_init(pkg, depth = 1L)
  dir_create(path(pkg$dst_path, "reference"))

  # Copy icons, if needed
  src_icons <- path(pkg$src_path, "icons")
  dst_icons <- path(pkg$dst_path, "reference", "icons")
  if (file_exists(src_icons)) {
    dir_copy_to(pkg, src_icons, dst_icons)
  }

  render_page(
    pkg, "reference-index",
    data = data_reference_index(pkg),
    path = "reference/index.html"
  )

  invisible()
}


build_reference_topic <- function(topic,
                                  pkg,
                                  lazy = TRUE,
                                  examples_env = globalenv(),
                                  run_dont_run = FALSE ) {

  in_path <- path(pkg$src_path, "man", topic$file_in)
  out_path <- path(pkg$dst_path, "reference", topic$file_out)

  if (lazy && !out_of_date(in_path, out_path))
    return(invisible())

  cli::cli_inform("Reading {src_path(path('man', topic$file_in))}")

  data <- withCallingHandlers(
    data_reference_topic(
      topic,
      pkg,
      examples_env = examples_env,
      run_dont_run = run_dont_run
    ),
    error = function(err) {
      cli::cli_abort("Failed to parse Rd in {.file {topic$file_in}}", parent = err)
    }
  )

  deps <- data$dependencies
  data$has_deps <- !is.null(deps)
  if (data$has_deps) {
    deps <- bs_theme_deps_suppress(deps)
    deps <- htmltools::resolveDependencies(deps)
    deps <- purrr::map(
      deps,
      htmltools::copyDependencyToDir,
      outputDir = file.path(pkg$dst_path, "reference", "libs"),
      mustWork = FALSE
    )
    deps <- purrr::map(
      deps,
      htmltools::makeDependencyRelative,
      basepath = file.path(pkg$dst_path, "reference"),
      mustWork = FALSE
    )
    data$dependencies <- htmltools::renderDependencies(deps, c("file", "href"))
  }

  render_page(
    pkg, "reference-topic",
    data = data,
    path = path("reference", topic$file_out)
  )

  invisible()
}


# Convert Rd to list ------------------------------------------------------

data_reference_topic <- function(topic,
                                 pkg,
                                 examples_env = globalenv(),
                                 run_dont_run = FALSE) {

  local_context_eval(pkg$figures, pkg$src_path)
  withr::local_options(list(downlit.rdname = get_rdname(topic)))

  tag_names <- purrr::map_chr(topic$rd, ~ class(.)[[1]])
  tags <- split(topic$rd, tag_names)

  out <- list()

  # Single top-level converted to string
  out$name <- flatten_text(tags$tag_name[[1]][[1]])
  out$title <- extract_title(tags$tag_title)
  out$pagetitle <- paste0(strip_html_tags(out$title), " \u2014 ", out$name)

  # File source
  out$source <- repo_source(pkg, topic$source)
  out$filename <- topic$file_in

  # Multiple top-level converted to string
  out$author <- purrr::map_chr(tags$tag_author %||% list(), flatten_para)
  out$aliases <- purrr::map_chr(tags$tag_alias %||% list(), flatten_text)
  out$keywords <- purrr::map_chr(tags$tag_keyword %||% list(), flatten_text)

  # Sections that contain arbitrary text and need cross-referencing
  out$description <- as_data(tags$tag_description[[1]])
  out$opengraph <- list(description = strip_html_tags(out$description$contents))
  if (length(tags$tag_usage[[1]])) {
    out$usage <- list(
      title = tr_("Usage"),
      contents = as_data(tags$tag_usage[[1]])
    )
  }


  if (!is.null(tags$tag_examples)) {
    out$examples <- run_examples(
      tags$tag_examples[[1]],
      env = if (is.null(examples_env)) NULL else new.env(parent = examples_env),
      topic = tools::file_path_sans_ext(topic$file_in),
      run_dont_run = run_dont_run
    )
    deps <- attr(out$examples, "dependencies")
    if (!is.null(deps)) {
      attr(out$examples, "dependencies") <- NULL
      out$dependencies <- deps
    }
  }

  # Everything else stays in original order, and becomes a list of sections.
  section_tags <- paste0("tag_", c(
    "arguments", "value", "details", "references", "source", "format", "note",
    "seealso", "section", "author"
  ))
  sections <- topic$rd[tag_names %in% section_tags]
  out$sections <- sections %>%
    purrr::map(as_data) %>%
    purrr::map(add_slug)

  out
}

add_slug <- function(x) {
  x$slug <- make_slug(x$title)
  x
}

make_slug <- function(x) {
  x <- strip_html_tags(x)
  x <- tolower(x)
  x <- gsub("[^a-z]+", "-", x)
  x
}

get_rdname <- function(topics) {
  gsub("\\.[Rr]d$", "", topics$file_in)
}
