#' Build reference section
#'
#' By default, pkgdown will generate an index that simply lists all
#' the functions in alphabetical order. To override this, provide a
#' \code{reference} section in your \code{_pkgdown.yml} as described
#' below.
#'
#' @section YAML config:
#' To tweak the index page, you need a section called \code{reference}
#' which provides a list of sections containing, a \code{title}, list of
#' \code{contents}, and optional \code{description}.
#'
#' For example, the following code breaks up the functions in pkgdown
#' into two groups:
#'
#' \preformatted{
#' reference:
#' - title: Render components
#'   desc:  Build each component of the site.
#'   contents:
#'   - starts_with("build_")
#'   - init_site
#' - title: Templates
#'   contents:
#'   - render_page
#' }
#'
#' Note that \code{contents} can contain either a list of function names,
#' or if the functions in a section share a common prefix or suffix, you
#' can use \code{starts_with("prefix")} and \code{ends_with("suffix")} to
#' select them all. For more complex naming schemes you can use an aribrary
#' regular expression with \code{matches("regexp")}. You can also use a leading
#' `-` to exclude matches from a section. By default, these functions that
#' match multiple topics will exclude topics with keyword "internal". To
#' include, use (e.g.) \code{starts_with("build_", internal = TRUE)}.
#'
#' Alternatively, you can selected topics that contain specified concepts with
#' \code{has_concept("blah")}. Concepts are not currently well-supported by
#' roxygen2, but may be useful if you write Rd files by hand.
#'
#' pkgdown will check that all non-internal topics are included on
#' this page, and will generate a warning if you have missed any.
#'
#' @section Icons:
#' You can optionally supply an icon for each help topic. To do so, you'll
#' need a top-level \code{icons} directory. This should contain {.png} files
#' that are either 40x40 (for regular display) or 80x80 (if you want
#' retina display). Icons are matched to topics by aliases.
#'
#' @inheritParams build_articles
#' @param lazy If \code{TRUE}, only rebuild pages where the \code{.Rd}
#'   is more recent than the \code{.html}. This makes it much easier to
#'   rapidly protoype. It is set to \code{FALSE} by \code{\link{build_site}}.
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
                            path = "docs/reference",
                            depth = 1L
                            ) {
  old <- set_pkgdown_env("true")
  on.exit(set_pkgdown_env(old))

  pkg <- as_pkgdown(pkg)
  path <- rel_path(path, pkg$path)

  rule("Building function reference")

  if (!is.null(path)) {
    mkdir(path)
  }

  # copy everything from man/figures to docs/reference/figures
  figures_path <- file.path(pkg$path, "man", "figures")
  if (file.exists(figures_path) && !is.null(path)) {
    out_path <- file.path(path, "figures")
    message("Copying man/figures/")
    mkdir(out_path)
    copy_dir(figures_path, out_path)
  }

  build_reference_index(pkg, path = path, depth = depth)

  if (examples) {
    devtools::load_all(pkg$path)
    set.seed(seed)
  }

  pkg$topics %>%
    purrr::transpose() %>%
    purrr::map(build_reference_topic, path,
      pkg = pkg,
      lazy = lazy,
      depth = depth,
      examples = examples,
      run_dont_run = run_dont_run,
      mathjax = mathjax
    )
  invisible()
}

#' @export
#' @rdname build_reference
build_reference_index <- function(pkg = ".", path = "docs/reference", depth = 1L) {
  pkg <- as_pkgdown(pkg)
  path <- rel_path(path, pkg$path)

  # Copy icons, if needed
  logo_path <- file.path(pkg$path, "icons")
  if (file.exists(logo_path)) {
    mkdir(path, "icons")
    copy_dir(logo_path, file.path(path, "icons"))
  }

  render_page(
    pkg, "reference-index",
    data = data_reference_index(pkg, depth = depth),
    path = out_path(path, "index.html"),
    depth = depth
  )
}


build_reference_topic <- function(topic,
                                  pkg,
                                  lazy = TRUE,
                                  examples = TRUE,
                                  run_dont_run = FALSE,
                                  mathjax = TRUE,
                                  path = NULL,
                                  depth = 1L
                                  ) {

  message("Processing ", topic$file_in)

  in_path <- file.path(pkg$path, "man", topic$file_in)
  out_path <- out_path(path, topic$file_out)

  if (lazy && !out_of_date(in_path, out_path))
    return(invisible())

  render_page(
    pkg, "reference-topic",
    data = data_reference_topic(
      topic,
      pkg,
      path = path,
      examples = examples,
      run_dont_run = run_dont_run,
      mathjax = mathjax,
      depth = depth
    ),
    path = out_path,
    depth = depth
  )
  invisible()
}


# Convert Rd to list ------------------------------------------------------

data_reference_topic <- function(topic,
                                 pkg,
                                 examples = TRUE,
                                 run_dont_run = FALSE,
                                 mathjax = TRUE,
                                 path = NULL,
                                 depth = 1L
                                 ) {

  tag_names <- purrr::map_chr(topic$rd, ~ class(.)[[1]])
  tags <- split(topic$rd, tag_names)

  out <- list()

  # Single top-level converted to string
  out$name <- flatten_text(tags$tag_name[[1]][[1]])
  out$title <- extract_title(tags$tag_title)

  out$pagetitle <- paste0(out$title, " \u2014 ", out$name)

  # Multiple top-level converted to string
  out$aliases <- purrr::map_chr(tags$tag_alias %||% list(), flatten_text)
  out$author <- purrr::map_chr(tags$tag_author %||% list(), flatten_text)
  out$keywords <- purrr::map_chr(tags$tag_keyword %||% list(), flatten_text)

  # Sections that contain arbitrary text and need cross-referencing
  out$description <- as_data(
    tags$tag_description[[1]],
    index = pkg$topics,
    current = get_current(topic, pkg)
  )

  out$usage <- as_data(
    tags$tag_usage[[1]],
    index = pkg$topics,
    current = get_current(topic, pkg)
  )

  out$arguments <- as_data(
    tags$tag_arguments[[1]],
    index = pkg$topics,
    current = get_current(topic, pkg)
  )
  if (length(out$arguments)) {
    out$has_args <- TRUE # Work around mustache deficiency
  }

  out$examples <- as_data(
    tags$tag_examples[[1]],
    env = new.env(parent = globalenv()),
    topic = tools::file_path_sans_ext(topic$file_in),
    index = pkg$topics,
    current = get_current(topic, pkg),
    path = path,
    examples = examples,
    run_dont_run = run_dont_run,
    depth = depth
  )

  # Everything else stays in original order, and becomes a list of sections.
  section_tags <- c(
    "tag_details", "tag_references", "tag_source", "tag_format",
    "tag_note", "tag_seealso", "tag_section", "tag_value"
  )
  sections <- topic$rd[tag_names %in% section_tags]
  out$sections <- sections %>%
    purrr::map(as_data, index = pkg$topics, current = get_current(topic, pkg)) %>%
    purrr::map(add_slug)

  out
}

add_slug <- function(x) {
  x$slug <- make_slug(x$title)
  x
}

make_slug <- function(x) {
  x <- tolower(x)
  x <- gsub("[^a-z]+", "-", x)
  x
}

get_current <- function(topic, pkg) {
  new_current(topic$name, pkg$desc$get("Package"))
}

new_current <- function(topic_name, pkg_name) {
  structure(topic_name, pkg_name = pkg_name)
}
