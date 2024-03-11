#' Build articles section
#'
#' @description
#' `build_articles()` renders each R Markdown file underneath `vignettes/` and
#' saves it to `articles/`. There are two exceptions:
#'
#' * Files that start with `_` (e.g., `_index.Rmd`) are ignored,
#'   enabling the use of child documents in
#'   [bookdown](https://bookdown.org/yihui/bookdown/)
#'
#' * Files in `vignettes/tutorials` are handled by [build_tutorials()]
#'
#' Vignettes are rendered using a special document format that reconciles
#' [rmarkdown::html_document()] with the pkgdown template. This means articles
#' behave slightly differently to vignettes, particularly with respect to
#' external files, and custom output formats. See below for more details.
#'
#' Note that when you run `build_articles()` directly (outside of
#' [build_site()]) vignettes will use the currently installed version of the
#' package, not the current source version. This makes iteration quicker when
#' you are primarily working on the text of an article.
#'
#' @section Index and navbar:
#' You can control the articles index and navbar with a `articles` field in
#' your `_pkgdown.yml`. If you use it, pkgdown will check that all articles
#' are included, and will error if you have missed any.
#'
#' The `articles` field defines a list of sections, each of which
#' can contain four fields:
#'
#' * `title` (required): title of section, which appears as a heading on the
#'   articles index.
#'
#' * `desc` (optional): An optional markdown description displayed underneath
#'   the section title.
#'
#' * `navbar` (optional): A couple of words used to label this section in
#'   the navbar. If omitted, this section of vignettes will not appear in the
#'   navbar.
#'
#' * `contents` (required): a list of article names to include in the
#'   section. This can either be names of individual vignettes or a
#'   call to `starts_with()`. The name of a vignette includes its
#'   path under `vignettes` without extension so that the name of the vignette
#'   found at `vignettes/pizza/slice.Rmd` is `pizza/slice`.
#'
#' The title and description of individual vignettes displayed on the index
#' comes from `title` and `description` fields of the YAML header in the Rmds.
#'
#' For example, this yaml might be used for some version of dplyr:
#'
#' ```yaml
#' articles:
#' - title: Main verbs
#'   navbar: ~
#'   contents:
#'   - one-table
#'   - two-table
#'   - rowwise
#'   - colwise
#'
#' - title: Developer
#'   desc: Vignettes aimed at package developers
#'   contents:
#'   - programming
#'   - packages
#' ```
#'
#' Note the use of the `navbar` fields. `navbar: ~` means that the "Main verbs"
#' will appear in the navbar without a heading; the absence of the `navbar`
#' field in the developer vignettes means that they will only be
#' accessible via the articles index.
#'
#' The navbar will include a link to the articles index if one or more
#' vignettes are not available through the navbar. If some vignettes appear
#' in the navbar drop-down list and others do not, the list will automatically
#' include a "More ..." link at the bottom; if no vignettes appear in the
#' the navbar, it will link directly to the articles index instead of
#' providing a drop-down.
#'
#' @section Get started:
#' Note that a vignette with the same name as the package (e.g.,
#' `vignettes/pkgdown.Rmd` or `vignettes/articles/pkgdown.Rmd`) automatically
#' becomes a top-level "Get started" link, and will not appear in the articles
#' drop-down.
#'
#' (If your package name includes a `.`, e.g. `pack.down`, use a `-` in the
#' vignette name, e.g. `pack-down.Rmd`.)
#'
#' @section External files:
#' pkgdown differs from base R in its handling of external files. When building
#' vignettes, R assumes that vignettes are self-contained (a reasonable
#' assumption when most vignettes were PDFs) and only copies files explicitly
#' listed in `.install_extras`. pkgdown takes a different approach based on
#' [rmarkdown::find_external_resources()], and it will also copy any images that
#' you link to. If for some reason the automatic detection doesn't work, you
#' will need to add a `resource_files` field to the yaml metadata, e.g.:
#'
#' ```yaml
#' ---
#' title: My Document
#' resource_files:
#'   - data/mydata.csv
#'   - images/figure.png
#' ---
#' ```
#'
#' Note that you can not use the `fig.path` to change the output directory of
#' generated figures as its default value is a strong assumption of rmarkdown.
#'
#' @section Embedding Shiny apps:
#' If you would like to embed a Shiny app into an article, the app will have
#' to be hosted independently, (e.g. <https://www.shinyapps.io>). Then, you
#' can embed the app into your article using an `<iframe>`, e.g.
#' `<iframe src = "https://gallery.shinyapps.io/083-front-page" class="shiny-app">`.
#'
#' See <https://github.com/r-lib/pkgdown/issues/838#issuecomment-430473856> for
#' some hints on how to customise the appearance with CSS.
#'
#' @section Output formats:
#' By default, pkgdown builds all articles using the
#' [rmarkdown::html_document()] `output` format, ignoring whatever is set in
#' your YAML metadata. This is necessary because pkgdown has to integrate the
#' HTML/CSS/JS from the vignette with the HTML/CSS/JS from rest of the site.
#' Because of the challenges of combining two sources of HTML/CSS/JS, there is
#' limited support for other output formats and you have to opt-in by setting
#' the `as_is` field in your `.Rmd` metadata:
#'
#' ```yaml
#' pkgdown:
#'   as_is: true
#' ```
#'
#' If the output format produces a PDF, you'll also need to specify the
#' `extension` field:
#'
#' ```yaml
#' pkgdown:
#'   as_is: true
#'   extension: pdf
#' ```
#'
#' To work with pkgdown, the output format must accept `template`, `theme`, and
#' `self_contained` arguments, and must work without any additional CSS or
#' JSS files. Note that if you use
#' [`_output.yml`](https://bookdown.org/yihui/rmarkdown/html-document.html#shared-options)
#' or [`_site.yml`](https://rmarkdown.rstudio.com/docs/reference/render_site.html)
#' you'll still need to add `as_is: true` to each individual vignette.
#'
#' Additionally, htmlwidgets do not work when `as_is: true`.
#'
#' @inheritSection build_reference Figures
#'
#' @section Suppressing vignettes:
#' If you want articles that are not vignettes, either put them in
#' subdirectories or list in `.Rbuildignore`. An articles link will be
#' automatically added to the default navbar if the vignettes directory is
#' present: if you do not want this, you will need to customise the navbar. See
#' [build_site()] details.
#'
#' @inheritParams as_pkgdown
#' @param quiet Set to `FALSE` to display output of knitr and
#'   pandoc. This is useful when debugging.
#' @param lazy If `TRUE`, will only re-build article if input file has been
#'   modified more recently than the output file.
#' @param preview If `TRUE`, or `is.na(preview) && interactive()`, will preview
#'   freshly generated section in browser.
#' @export
build_articles <- function(pkg = ".",
                           quiet = TRUE,
                           lazy = TRUE,
                           override = list(),
                           preview = NA) {
  pkg <- section_init(pkg, depth = 1L, override = override)

  if (nrow(pkg$vignettes) == 0L) {
    return(invisible())
  }

  cli::cli_rule("Building articles")

  build_articles_index(pkg)
  purrr::walk(
    pkg$vignettes$name, build_article,
    pkg = pkg,
    quiet = quiet,
    lazy = lazy
  )

  preview_site(pkg, "articles", preview = preview)
}

#' @export
#' @rdname build_articles
#' @param name Name of article to render. This should be either a path
#'   relative to `vignettes/` without extension, or `index` or `README`.
#' @param data Additional data to pass on to template.
build_article <- function(name,
                           pkg = ".",
                           data = list(),
                           lazy = FALSE,
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
  front_opengraph <- check_open_graph(front$opengraph %||% list())
  data$opengraph <- utils::modifyList(
    data$opengraph %||% list(), front_opengraph
  )

  # Allow users to opt-in to their own template
  ext <- purrr::pluck(front, "pkgdown", "extension", .default = "html")
  as_is <- isTRUE(purrr::pluck(front, "pkgdown", "as_is"))

  default_data <- list(
    pagetitle = front$title,
    toc = toc <- front$toc %||% TRUE,
    opengraph = list(description = front$description %||% pkg$package),
    source = repo_source(pkg, path_rel(input, pkg$src_path)),
    filename = path_file(input),
    output_file = output_file,
    as_is = as_is
  )
  data <- utils::modifyList(default_data, data)

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
    extra_dependencies = bs_theme_deps_suppress()
  )
  out$knitr$opts_chunk <- fig_opts_chunk(pkg$figures, out$knitr$opts_chunk)

  old_pre <- out$pre_knit
  out$pre_knit <- function(...) {
    options(width = purrr::pluck(pkg, "meta", "code", "width", .default = 80))
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

# Articles index ----------------------------------------------------------

#' @export
#' @rdname build_articles
build_articles_index <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  dir_create(path(pkg$dst_path, "articles"))
  render_page(
    pkg,
    "article-index",
    data = data_articles_index(pkg),
    path = path("articles", "index.html")
  )
}

data_articles_index <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  meta <- pkg$meta$articles %||% default_articles_index(pkg)
  sections <- meta %>%
    purrr::map(data_articles_index_section, pkg = pkg) %>%
    purrr::compact()

  # Check for unlisted vignettes
  listed <- sections %>%
    purrr::map("contents") %>%
    purrr::map(. %>% purrr::map_chr("name")) %>%
    purrr::flatten_chr() %>%
    unique()

  missing <- setdiff(pkg$vignettes$name, c(listed, pkg$package))

  if (length(missing) > 0) {
    cli::cli_abort(
      "{length(missing)} vignette{?s} missing from index in \\
      {pkgdown_config_href({pkg$src_path})}: {.val {missing}}.",
      call = caller_env()
    )
  }

  print_yaml(list(
    pagetitle = tr_("Articles"),
    sections = sections
  ))
}

data_articles_index_section <- function(section, pkg) {
  if (!set_contains(names(section), c("title", "contents"))) {
    cli::cli_abort(
      "Section must have components {.field title}, {.field contents}",
      call = caller_env()
    )
  }

  # Match topics against any aliases
  in_section <- select_vignettes(section$contents, pkg$vignettes)
  section_vignettes <- pkg$vignettes[in_section, ]
  contents <- tibble::tibble(
    name = section_vignettes$name,
    path = path_rel(section_vignettes$file_out, "articles"),
    title = section_vignettes$title,
    description = lapply(section_vignettes$description, markdown_text_block),
  )

  list(
    title = markdown_text_inline(section$title),
    desc = markdown_text_block(section$desc),
    class = section$class,
    contents = purrr::transpose(contents)
  )
}

# Quick hack: create the same structure as for topics so we can use
# the existing select_topics()
select_vignettes <- function(match_strings, vignettes) {
  topics <- tibble::tibble(
    name = vignettes$name,
    alias = as.list(vignettes$name),
    internal = FALSE
  )
  select_topics(match_strings, topics)
}

default_articles_index <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  if (nrow(pkg$vignettes) == 0L) {
    return(NULL)
  }

  print_yaml(list(
    list(
      title = tr_("All vignettes"),
      desc = NULL,
      contents = paste0("`", pkg$vignettes$name, "`")
    )
  ))
}

article_is_intro <- function(name, package) {
  package <- gsub(".", "-", package, fixed = TRUE)
  name %in% c(package, paste0("articles/", package))
}
