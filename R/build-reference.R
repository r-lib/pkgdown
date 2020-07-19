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
#' ```
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
#' ```
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
#' ```
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
#'
#' All functions (except for `has_keywords()`) automatically exclude internal
#' topics (i.e. those with `\keyword{internal}`). You can choose to include
#' with (e.g.) `starts_with("build_", internal = TRUE)`.
#'
#' Use a leading `-` to remove topics from a section, e.g. `-topic_name`,
#' `-starts_with("foo")`.
#'
#' pkgdown will check that all non-internal topics are included on
#' the reference index page, and will generate a warning if you have missed any.
#'
#' ## Icons
#' You can optionally supply an icon for each help topic. To do so, you'll need
#' a top-level `icons` directory. This should contain {.png} files that are
#' either 30x30 (for regular display) or 60x60 (if you want retina display).
#' Icons are matched to topics by aliases.
#'
#' @section Figures:
#'
#' You can control the default rendering of figures by specifying the `figures`
#' field in `_pkgdown.yml`. The default settings are equivalent to:
#'
#' ```
#' figures:
#'   dev: grDevices::png
#'   dpi: 96
#'   dev.args: []
#'   fig.ext: png
#'   fig.width: 7.2916667
#'   fig.height: ~
#'   fig.retina: 2
#'   fig.asp: 1.618
#' ```
#'
#' @inheritParams build_articles
#' @param lazy If `TRUE`, only rebuild pages where the `.Rd`
#'   is more recent than the `.html`. This makes it much easier to
#'   rapidly prototype. It is set to `FALSE` by [build_site()].
#' @param run_dont_run Run examples that are surrounded in \\dontrun?
#' @param examples Run examples?
#' @param seed Seed used to initialize so that random examples are
#'   reproducible.
#' @param devel Determines how code is loaded in order to run examples.
#'   If `TRUE` (the default), assumes you are in a live development
#'   environment, and loads source package with [pkgload::load_all()].
#'   If `FALSE`, uses the installed version of the package.
#' @param document **Deprecated** Use `devel` instead.
#' @param topics Build only specified topics. If supplied, sets `lazy``
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

  if (!missing(document)) {
    warning("`document` is deprecated. Please use `devel` instead.", call. = FALSE)
    devel <- document
  }

  rule("Building function reference")
  build_reference_index(pkg)

  # copy everything from man/figures to docs/reference/figures
  src_figures <- path(pkg$src_path, "man", "figures")
  dst_figures <- path(pkg$dst_path, "reference", "figures")
  if (file_exists(src_figures)) {
    dir_copy_to(pkg, src_figures, dst_figures)
  }

  if (examples) {
    # Re-loading pkgdown while it's running causes weird behaviour with
    # the context cache
    if (isTRUE(devel) && !(pkg$package %in% c("pkgdown", "rprojroot"))) {
      if (!is_installed("pkgload")) {
        abort("Please install pkgload to use `build_reference(devel = TRUE)`")
      }
      pkgload::load_all(pkg$src_path, export_all = FALSE, helpers = FALSE)
    } else {
      library(pkg$package, character.only = TRUE)
    }

    old_dir <- setwd(path(pkg$dst_path, "reference"))
    on.exit(setwd(old_dir), add = TRUE)

    old_opt <- options(width = 80)
    on.exit(options(old_opt), add = TRUE)

    set.seed(seed)
  }

  if (!is.null(topics)) {
    topics <- purrr::transpose(pkg$topics[pkg$topics$name %in% topics, ])
    lazy <- FALSE
    preview <- FALSE
  } else {
    topics <- purrr::transpose(pkg$topics)
  }

  purrr::map(topics,
    build_reference_topic,
    pkg = pkg,
    lazy = lazy,
    examples = examples,
    run_dont_run = run_dont_run
  )

  preview_site(pkg, "reference", preview = preview)
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

  invisible(render_page(
    pkg, "reference-index",
    data = data_reference_index(pkg),
    path = "reference/index.html"
  ))
}


build_reference_topic <- function(topic,
                                  pkg,
                                  lazy = TRUE,
                                  examples = TRUE,
                                  run_dont_run = FALSE
                                  ) {

  in_path <- path(pkg$src_path, "man", topic$file_in)
  out_path <- path(pkg$dst_path, "reference", topic$file_out)

  if (lazy && !out_of_date(in_path, out_path))
    return(invisible())

  cat_line("Reading ", src_path("man", topic$file_in))

  data <- withCallingHandlers(
    data_reference_topic(
      topic,
      pkg,
      examples = examples,
      run_dont_run = run_dont_run
    ),
    error = function(err) {
      msg <- c(
        paste0("Failed to parse Rd in ", topic$file_in),
        i = err$message
      )
      abort(msg, parent = err)
    }
  )

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
                                 examples = TRUE,
                                 run_dont_run = FALSE
                                 ) {
  local_context_eval(pkg$figures, pkg$src_path)
  withr::local_options(list(downlit.rdname = topic$name))

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
  out$usage <- as_data(tags$tag_usage[[1]])
  out$arguments <- as_data(tags$tag_arguments[[1]])
  if (length(out$arguments)) {
    out$has_args <- TRUE # Work around mustache deficiency
  }

  if (!is.null(tags$tag_examples)) {
    out$examples <- run_examples(
      tags$tag_examples[[1]],
      env = new.env(parent = globalenv()),
      topic = tools::file_path_sans_ext(topic$file_in),
      run_examples = examples,
      run_dont_run = run_dont_run
    )
  }

  # Everything else stays in original order, and becomes a list of sections.
  section_tags <- c(
    "tag_details", "tag_references", "tag_source", "tag_format",
    "tag_note", "tag_seealso", "tag_section", "tag_value", "tag_author"
  )
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
