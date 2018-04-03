#' Build reference section
#'
#' By default, pkgdown will generate an index that simply lists all
#' the functions in alphabetical order. To override this, provide a
#' `reference` section in your `_pkgdown.yml` as described
#' below.
#'
#' @section YAML config:
#' To tweak the index page, you need a section called `reference`
#' which provides a list of sections containing, a `title`, list of
#' `contents`, and optional `description`.
#'
#' For example, the following code breaks up the functions in pkgdown
#' into two groups:
#'
#' ```
#' reference:
#' - title: Render components
#'   desc:  Build each component of the site.
#'   contents:
#'   - starts_with("build_")
#'   - init_site
#' - title: Templates
#'   contents:
#'   - render_page
#' ```
#'
#' Note that `contents` can contain either a list of function names,
#' or if the functions in a section share a common prefix or suffix, you
#' can use `starts_with("prefix")` and `ends_with("suffix")` to
#' select them all. For more complex naming schemes you can use an aribrary
#' regular expression with `matches("regexp")`. You can also use a leading
#' `-` to exclude matches from a section. By default, these functions that
#' match multiple topics will exclude topics with keyword "internal". To
#' include, use (e.g.) `starts_with("build_", internal = TRUE)`.
#'
#' Alternatively, you can selected topics that contain specified concepts with
#' `has_concept("blah")`. Concepts are not currently well-supported by
#' roxygen2, but may be useful if you write Rd files by hand.
#'
#' pkgdown will check that all non-internal topics are included on
#' this page, and will generate a warning if you have missed any.
#'
#' @section Figures:
#'
#' You can control the default rendering of figues by specifying the `figures`
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
#' @section Icons:
#' You can optionally supply an icon for each help topic. To do so, you'll
#' need a top-level `icons` directory. This should contain {.png} files
#' that are either 40x40 (for regular display) or 80x80 (if you want
#' retina display). Icons are matched to topics by aliases.
#'
#' @inheritParams build_articles
#' @param lazy If `TRUE`, only rebuild pages where the `.Rd`
#'   is more recent than the `.html`. This makes it much easier to
#'   rapidly protoype. It is set to `FALSE` by [build_site()].
#' @param run_dont_run Run examples that are surrounded in \\dontrun?
#' @param examples Run examples?
#' @param mathjax Use mathjax to render math symbols?
#' @param seed Seed used to initialize so that random examples are
#'   reproducible.
#' @export
#' @examples
#' # This example illustrates some important output types
#' # The following output should be wrapped over multiple lines
#' a <- 1:100
#' a
#'
#' cat("This some text!\n")
#' message("This is a message!")
#' warning("This is a warning!")
#'
#' # This is a multi-line block
#' {
#'   1 + 2
#'   2 + 2
#' }
#'
#' \dontrun{
#' stop("This is an error!", call. = FALSE)
#' }
#'
#' \donttest{
#' # This code won't generally be run by CRAN. But it
#' # will be run by pkgdown
#' b <- 10
#' a + b
#' }
build_reference <- function(pkg = ".",
                            lazy = TRUE,
                            examples = TRUE,
                            run_dont_run = FALSE,
                            mathjax = TRUE,
                            seed = 1014,
                            override = list(),
                            preview = NA
                            ) {
  pkg <- section_init(pkg, depth = 1L, override = override)
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
    if (!(pkg$package %in% c("pkgdown", "rprojroot"))) {
      pkgload::load_all(pkg$src_path)
    }

    old_dir <- setwd(path(pkg$dst_path, "reference"))
    on.exit(setwd(old_dir), add = TRUE)

    old_opt <- options(width = 80)
    on.exit(options(old_opt), add = TRUE)

    set.seed(seed)
  }

  topics <- purrr::transpose(pkg$topics)
  purrr::map(topics,
    build_reference_topic,
    pkg = pkg,
    lazy = lazy,
    examples = examples,
    run_dont_run = run_dont_run,
    mathjax = mathjax
  )

  preview_site(pkg, "reference", preview = preview)
}

#' @export
#' @rdname build_reference
build_reference_index <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)
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
}


build_reference_topic <- function(topic,
                                  pkg,
                                  lazy = TRUE,
                                  examples = TRUE,
                                  run_dont_run = FALSE,
                                  mathjax = TRUE
                                  ) {

  in_path <- path(pkg$src_path, "man", topic$file_in)
  out_path <- path(pkg$dst_path, "reference", topic$file_out)

  if (lazy && !out_of_date(in_path, out_path))
    return(invisible())

  cat_line("Reading ", src_path("man", topic$file_in))
  scoped_file_context(rdname = path_ext_remove(topic$file_in), depth = 1L)

  data <- data_reference_topic(
    topic,
    pkg,
    examples = examples,
    run_dont_run = run_dont_run,
    mathjax = mathjax
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
                                 run_dont_run = FALSE,
                                 mathjax = TRUE
                                 ) {
  tag_names <- purrr::map_chr(topic$rd, ~ class(.)[[1]])
  tags <- split(topic$rd, tag_names)

  out <- list()

  # Single top-level converted to string
  out$name <- flatten_text(tags$tag_name[[1]][[1]])
  out$title <- extract_title(tags$tag_title)

  out$pagetitle <- paste0(out$title, " \u2014 ", out$name)

  # File source
  out$source <- github_source_links(pkg$github_url, topic$source)
  out$filename <- topic$file_in

  # Multiple top-level converted to string
  out$aliases <- purrr::map_chr(tags$tag_alias %||% list(), flatten_text)
  out$author <- purrr::map_chr(tags$tag_author %||% list(), flatten_text)
  out$keywords <- purrr::map_chr(tags$tag_keyword %||% list(), flatten_text)

  # Sections that contain arbitrary text and need cross-referencing
  out$description <- as_data(tags$tag_description[[1]])
  out$opengraph <- list(description = strip_html_tags(out$description$contents))
  out$usage <- as_data(tags$tag_usage[[1]])
  out$arguments <- as_data(tags$tag_arguments[[1]])
  if (length(out$arguments)) {
    out$has_args <- TRUE # Work around mustache deficiency
  }

  out$examples <- as_data(
    tags$tag_examples[[1]],
    env = new.env(parent = globalenv()),
    topic = tools::file_path_sans_ext(topic$file_in),
    examples = examples,
    run_dont_run = run_dont_run
  )

  # Everything else stays in original order, and becomes a list of sections.
  section_tags <- c(
    "tag_details", "tag_references", "tag_source", "tag_format",
    "tag_note", "tag_seealso", "tag_section", "tag_value"
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
