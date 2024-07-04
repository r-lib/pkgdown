#' Build articles section
#'
#' @description
#' `build_articles()` renders each R Markdown file underneath `vignettes/` and
#' saves it to `articles/`. There are two exceptions:
#'
#' * Files that start with `_` (e.g., `_index.Rmd`) are ignored,
#'   enabling the use of child documents.
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
#' # Index and navbar
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
#' ## Get started
#' Note that a vignette with the same name as the package (e.g.,
#' `vignettes/pkgdown.Rmd` or `vignettes/articles/pkgdown.Rmd`) automatically
#' becomes a top-level "Get started" link, and will not appear in the articles
#' drop-down.
#'
#' (If your package name includes a `.`, e.g. `pack.down`, use a `-` in the
#' vignette name, e.g. `pack-down.Rmd`.)
#'
#' ## Missing articles
#'
#' pkgdown will warn if there are (non-internal) articles that aren't listed
#' in the articles index. You can suppress such warnings by listing the
#' affected articles in a section with `title: internal` (case sensitive);
#' this section will not be displayed on the index page.
#' 
#' ## External articles
#'
#' You can link to arbitrary additional articles by adding an 
#' `external-articles` entry to `_pkgdown.yml`. It should contain an array
#' of objects with fields `name`, `title`, `href`, and `description`. 
#'
#' ```yaml
#' external-articles:
#' - name: subsampling
#'   title: Subsampling for Class Imbalances
#'   description: Improve model performance in imbalanced data sets through undersampling or oversampling.
#'   href: https://www.tidymodels.org/learn/models/sub-sampling/
#' ```
#' 
#' If you've defined a custom articles index, you'll need to include the name
#' in one of the `contents` fields.
#'
#' # External files
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
#' # Embedding Shiny apps
#' If you would like to embed a Shiny app into an article, the app will have
#' to be hosted independently, (e.g. <https://www.shinyapps.io>). Then, you
#' can embed the app into your article using an `<iframe>`, e.g.
#' `<iframe src = "https://gallery.shinyapps.io/083-front-page" class="shiny-app">`.
#'
#' See <https://github.com/r-lib/pkgdown/issues/838#issuecomment-430473856> for
#' some hints on how to customise the appearance with CSS.
#'
#' # Output formats
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
#' # Suppressing vignettes
#' If you want [articles](https://r-pkgs.org/vignettes.html#sec-vignettes-article)
#' that are not vignettes, use `usethis::use_article()` to create it. An articles link will be
#' automatically added to the default navbar if the vignettes directory is
#' present: if you do not want this, you will need to customise the navbar. See
#' [build_site()] details.
#'
#' @inheritSection build_reference Figures
#' @family site components
#'
#' @inheritParams as_pkgdown
#' @param quiet Set to `FALSE` to display output of knitr and
#'   pandoc. This is useful when debugging.
#' @param lazy If `TRUE`, will only re-build article if input file has been
#'   modified more recently than the output file.
#' @param seed Seed used to initialize random number generation in order to
#'   make article output reproducible. An integer scalar or `NULL` for no seed.
#' @param preview If `TRUE`, or `is.na(preview) && interactive()`, will preview
#'   freshly generated section in browser.
#' @export
#' @order 1
build_articles <- function(pkg = ".",
                           quiet = TRUE,
                           lazy = TRUE,
                           seed = 1014L,
                           override = list(),
                           preview = FALSE) {
  pkg <- section_init(pkg, "articles", override = override)
  check_bool(quiet)
  check_bool(lazy)
  check_number_whole(seed, allow_null = TRUE)

  if (nrow(pkg$vignettes) == 0L) {
    return(invisible())
  }

  cli::cli_rule("Building articles")

  build_articles_index(pkg)
  unwrap_purrr_error(purrr::walk(
    pkg$vignettes$name[pkg$vignettes$type == "rmd"],
    build_article,
    pkg = pkg,
    lazy = lazy,
    seed = seed,
    quiet = quiet
  ))
  build_quarto_articles(pkg, quiet = quiet)

  preview_site(pkg, "articles", preview = preview)
}

# Articles index ----------------------------------------------------------

#' @export
#' @rdname build_articles
#' @order 3
build_articles_index <- function(pkg = ".", override = list()) {
  pkg <- section_init(pkg, "articles", override = override)
  render_page(
    pkg,
    "article-index",
    data = data_articles_index(pkg),
    path = path("articles", "index.html")
  )
  invisible()
}

data_articles_index <- function(pkg = ".", call = caller_env()) {
  pkg <- as_pkgdown(pkg)

  articles <- data_articles(pkg, is_index = TRUE, call = call)
  index <- config_pluck_list(pkg, "articles", call = call) %||%
    default_articles_index(pkg)
  sections <- unwrap_purrr_error(purrr::imap(
    index,
    data_articles_index_section,
    articles = articles,
    pkg = pkg,
    call = call
  ))

  # Check for unlisted vignettes
  all_names <- purrr::map(sections, function(section) {
    purrr::map_chr(section$contents, "name")
  })
  listed <- unique(purrr::list_c(all_names))

  missing <- setdiff(articles$name, listed)
  # Exclude get started vignette or article #2150
  missing <- missing[!article_is_intro(missing, package = pkg$package)]

  if (length(missing) > 0) {
    config_abort(
      pkg,
      "{length(missing)} vignette{?s} missing from index: {.val {missing}}.",
      call = caller_env()
    )
  }

  # Remove internal section after missing vignettes check
  sections <- Filter(function(x) x$title != "internal", sections)

  print_yaml(list(
    pagetitle = tr_("Articles"),
    sections = sections
  ))
}

data_articles <- function(pkg = ".", is_index = FALSE, call = caller_env()) {
  pkg <- as_pkgdown(pkg)

  internal <- tibble::tibble(
    name = pkg$vignettes$name,
    title = pkg$vignettes$title,
    href = pkg$vignettes$file_out,
    description = pkg$vignettes$description,
  )
  if (is_index) {
    internal$href <- path_rel(internal$href, "articles")
  }

  external <- config_pluck_external_articles(pkg, call = call)
  articles <- rbind(internal, external)

  articles$description <- lapply(articles$description, markdown_text_block, pkg = pkg)

  # Hack data structure so we can use select_topics()
  articles$alias <- as.list(articles$name)
  articles$internal <- FALSE

  articles
}

config_pluck_external_articles <- function(pkg, call = caller_env()) {
  external <- config_pluck_list(pkg, "external-articles", call = call)
  if (is.null(external)) {
    return(tibble::tibble(
      name = character(),
      title = character(),
      href = character(),
      description = character()
    ))
  }

  for (i in seq_along(external)) {
    config_check_list(
      external[[i]],
      has_names = c("name", "title", "href", "description"),
      error_path = paste0("external-articles[", i, "]"),
      error_pkg = pkg,
      error_call = call
    )
    config_check_string(
      external[[i]]$name,
      error_path = paste0("external-articles[", i, "].name"),
      error_pkg = pkg,
      error_call = call
    )
    config_check_string(
      external[[i]]$title,
      error_path = paste0("external-articles[", i, "].title"),
      error_pkg = pkg,
      error_call = call
    )
    config_check_string(
      external[[i]]$href,
      error_path = paste0("external-articles[", i, "].href"),
      error_pkg = pkg,
      error_call = call
    )
    config_check_string(
      external[[i]]$description,
      error_path = paste0("external-articles[", i, "].description"),
      error_pkg = pkg,
      error_call = call
    )
  }

  tibble::tibble(
    name = purrr::map_chr(external, "name"),
    title = purrr::map_chr(external, "title"),
    href = purrr::map_chr(external, "href"),
    description = purrr::map_chr(external, "description")
  )
}

data_articles_index_section <- function(section, index, articles, pkg, call = caller_env()) {
  config_check_list(
    section,
    error_path = paste0("articles[", index, "]"),
    has_names = c("title", "contents"),
    error_pkg = pkg,
    error_call = call
  )
  config_check_string(
    section$title,
    error_path = paste0("articles[", index, "].title"),
    error_pkg = pkg,
    error_call = call
  )
  title <- markdown_text_inline(
    pkg,
    section$title,
    error_path = paste0("articles[", index, "].title"),
    error_call = call
  )

  config_check_string(
    section$desc,
    error_path = paste0("articles[", index, "].desc"),
    error_pkg = pkg,
    error_call = call
  )
  check_contents(
    section$contents,
    index,
    pkg,
    prefix = "articles",
    call = call
  )

  # Match topics against any aliases
  idx <- select_topics(
    section$contents,
    articles,
    error_path = paste0("articles[", index, "].contents"),
    error_pkg = pkg,
    error_call = call
  )
  contents <- articles[idx, , drop = FALSE]

  list(
    title = title,
    desc = markdown_text_block(pkg, section$desc),
    class = section$class,
    contents = purrr::transpose(contents)
  )
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
      contents = auto_quote(unname(pkg$vignettes$name))
    )
  ))
}

article_is_intro <- function(name, package) {
  package <- gsub(".", "-", package, fixed = TRUE)
  name %in% c(package, paste0("articles/", package))
}
