#' Generate reference index and topics.
#'
#' @inheritParams build_articles
#' @param run_dont_run Run examples that are surrounded in \\dontrun?
#' @param examples Run examples?
#' @param mathjax Use mathjax to render math symbols?
#' @export
build_reference <- function(pkg = ".",
                            examples = TRUE,
                            run_dont_run = FALSE,
                            mathjax = TRUE,
                            path = NULL,
                            depth = 1L
                            ) {
  rule("Building function reference")
  if (!is.null(path)) {
    mkdir(path)
  }

  if (examples) {
    devtools::load_all(pkg$path)
  }

  pkg$topics %>%
    purrr::transpose() %>%
    purrr::map(build_reference_topic, path,
      pkg = pkg,
      depth = depth,
      examples = examples,
      run_dont_run = run_dont_run,
      mathjax = mathjax
    )

  build_reference_index(pkg, path = path, depth = depth)

  invisible()
}

build_reference_topic <- function(topic,
                                  pkg,
                                  examples = TRUE,
                                  run_dont_run = FALSE,
                                  mathjax = TRUE,
                                  path = NULL,
                                  depth = 1L
                                  ) {
  render_page(
    pkg, "reference-topic",
    data = data_reference_topic(
      topic,
      pkg,
      path = path,
      examples = examples,
      run_dont_run = run_dont_run,
      mathjax = mathjax
    ),
    path = out_path(path, topic$file_out),
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
                                 path = NULL
                                 ) {
  tag_names <- purrr::map_chr(topic$rd, ~ class(.)[[1]])
  tags <- split(topic$rd, tag_names)

  out <- list()

  # Single top-level converted to string
  out$name <- as_html(tags$tag_name[[1]][[1]])
  out$title <- as_html(tags$tag_title[[1]][[1]])

  out$pagetitle <- out$name

  # Multiple top-level converted to string
  out$aliases <- purrr::map_chr(tags$tag_alias %||% list(), flatten_text)
  out$author <- purrr::map_chr(tags$tag_author %||% list(), flatten_text)
  out$keywords <- purrr::map_chr(tags$tag_keyword %||% list(), flatten_text)

  # Sections that contain arbitrary text and need cross-referencing
  out$seealso <- as_data(tags$tag_seealso[[1]], pkg = pkg)
  out$usage <- as_data(tags$tag_usage[[1]], pkg = pkg)
  out$arguments <- as_data(tags$tag_arguments[[1]], pkg = pkg)
  if (length(out$arguments)) {
    out$has_args <- TRUE # Work around mustache deficiency
  }

  # Examples
  env <- new.env(parent = globalenv())
  out$examples <- as_data(tags$examples[[1]], env = env, pkg = pkg, path = path)

  # Everything else stays in original order, and becomes a list of sections.
  section_tags <- c(
    "tag_details", "tag_description", "tag_references", "tag_source",
    "tag_format", "tag_note", "tag_seealso", "tag_section", "tag_value"
  )
  sections <- topic$rd[tag_names %in% section_tags]
  out$sections <- purrr::map(sections, as_data, pkg = pkg)

  out
}


