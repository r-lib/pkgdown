#' Render page with template
#'
#' Each page is composed of four templates: "head", "header", "content", and
#' "footer". Each of these templates is rendered using the `data`, and
#' then assembled into an overall page using the "layout" template.
#'
#' @param pkg Path to package to document.
#' @param name Name of the template (e.g. "home", "vignette", "news")
#' @param data Data for the template.
#'
#'   This is automatically supplemented with three lists:
#'
#'   * `site`: `title` and path to `root`.
#'   * `yaml`: the `template` key from `_pkgdown.yml`.
#'   * `package`: package metadata including `name` and`version`.
#'
#'   See the full contents by running [data_template()].
#' @param path Location to create file; relative to destination directory.
#' @param depth Depth of path relative to base directory.
#' @param quiet If `quiet`, will suppress output messages
#' @export
render_page <- function(pkg = ".", name, data, path, depth = NULL, quiet = FALSE) {
  pkg <- as_pkgdown(pkg)

  if (is.null(depth)) {
    depth <- length(strsplit(path, "/")[[1]]) - 1L
  }

  html <- render_page_html(pkg, name = name, data = data, depth = depth)

  tweak_page(html, name, pkg = pkg)
  if (pkg$bs_version > 3) {
    activate_navbar(html, data$output_file %||% path, pkg)
  }

  rendered <- as.character(html, options = character())
  write_if_different(pkg, rendered, path, quiet = quiet)
}

render_page_html <- function(pkg, name, data = list(), depth = 0L) {
  data <- utils::modifyList(data_template(pkg, depth = depth), data)

  # render template components
  pieces <- c(
    "head",
    "in-header",
    "before-body",
    "navbar",
    "content",
    "footer",
    "after-body",
    if (pkg$bs_version == 3) c("header", "docsearch")
  )

  templates <- purrr::map_chr(pieces, find_template, name = name, pkg = pkg)
  components <- purrr::map(templates, render_template, data = data)
  components <- purrr::set_names(components, pieces)
  components$template <- name
  components$lang <- pkg$lang
  components$translate <- data$translate

  # render complete layout
  template <- find_template("layout", name, pkg = pkg)
  rendered <- render_template(template, components)

  xml2::read_html(rendered, encoding = "UTF-8")
}

#' @export
#' @rdname render_page
data_template <- function(pkg = ".", depth = 0L) {
  pkg <- as_pkgdown(pkg)
  out <- list()

  # Basic metadata
  out$package <- list(
    name = pkg$package,
    version = as.character(pkg$version)
  )
  out$logo <- list(src = logo_path(pkg, depth = depth))
  out$site <- list(
    root = up_path(depth),
    title = pkg$meta$title %||% pkg$package
  )
  out$year <- strftime(Sys.time(), "%Y")

  # Language and translations
  out$lang <- pkg$lang
  out$translate <- list(
    skip = tr_("Skip to contents"),
    toggle_nav = tr_("Toggle navigation"),
    search_for = tr_("Search for"),
    on_this_page = tr_("On this page"),
    source = tr_("Source"),
    abstract = tr_("Abstract"),
    authors = tr_("Authors"),
    version = tr_("Version"),
    examples = tr_("Examples"),
    citation = tr_("Citation")
  )

  # Components that mostly end up in the <head>
  out$has_favicons <- has_favicons(pkg)
  out$opengraph <- data_open_graph(pkg)
  out$extra <- list(
    css = path_first_existing(pkg$src_path, "pkgdown", "extra.css"),
    js = path_first_existing(pkg$src_path, "pkgdown", "extra.js")
  )
  out$includes <- purrr::pluck(pkg, "meta", "template", "includes", .default = list())
  out$yaml <- purrr::pluck(pkg, "meta", "template", "params", .default = list())
  # Force inclusion so you can reliably refer to objects inside yaml
  # in the mustache templates
  out$yaml$.present <- TRUE
  if (pkg$bs_version > 3) {
    out$headdeps <- data_deps(pkg = pkg, depth = depth)
  }

  # Development settings; tooltip needs to be generated at render time
  out$development <- pkg$development
  out$development$version_tooltip <- version_tooltip(pkg$development$mode)

  out$navbar <- data_navbar(pkg, depth = depth)
  out$footer <- data_footer(pkg)

  print_yaml(out)
}

data_open_graph <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)
  og <- pkg$meta$template$opengraph %||% list()
  og <- check_open_graph(og)
  if (is.null(og$image) && !is.null(find_logo(pkg$src_path))) {
    og$image <- list(src = path_file(find_logo(pkg$src_path)))
  }
  if (!is.null(og$image) && !grepl("^http", og$image$src)) {
    site_url <- pkg$meta$url %||% "/"
    if (!grepl("/$", site_url)) {
      site_url <- paste0(site_url, "/")
    }
    og$image$src <- gsub("^man/figures/", "reference/figures/", og$image$src)
    og$image$src <- paste0(site_url, og$image$src)
  }

  og$twitter$creator <- og$twitter$creator %||% og$twitter$site
  og$twitter$site <- og$twitter$site %||% og$twitter$creator
  og
}

check_open_graph <- function(og) {
  if (!is.list(og)) {
    fog <- friendly_type_of(og)
    cli::cli_abort(
      "{.var opengraph} must be a list, not {.val fog}.",
      call = caller_env()
    )
  }
  supported_fields <- c("image", "twitter")
  unsupported_fields <- setdiff(names(og), supported_fields)
  if (length(unsupported_fields)) {
    cli::cli_warn(
      "Unsupported {.var opengraph} field{?s}: {.val unsupported_fields}."
    )
  }
  if ("twitter" %in% names(og)) {
    if (is.character(og$twitter) && length(og$twitter) == 1 && grepl("^@", og$twitter)) {
      cli::cli_abort(
        "The {.var opengraph: twitter} option must be a list.",
        call = caller_env()
      )
    }
    if (!is.list(og$twitter)) {
      cli::cli_abort(
        "The {.var opengraph: twitter} option must be a list.",
        call = caller_env()
      )
    }
    if (is.null(og$twitter$creator) && is.null(og$twitter$site)) {
      cli::cli_abort(
        "{.var opengraph: twitter} must include either {.val creator} or {.val site}.",
        call = caller_env()
      )
    }
  }
  if ("image" %in% names(og)) {
    if (is.character(og$image) && length(og$image) == 1) {
      cli::cli_abort(
        "The {.var opengraph: image} option must be a list.",
        call = caller_env()
      )
    }
    if (!is.list(og$image)) {
      cli::cli_abort(
        "The {.var opengraph: image} option must be a list.",
        call = caller_env()
      )
    }
  }
  og[intersect(supported_fields, names(og))]
}

render_template <- function(path, data) {
  template <- read_file(path)
  if (length(template) == 0)
    return("")

  whisker::whisker.render(template, data)
}

write_if_different <- function(pkg, contents, path, quiet = FALSE, check = TRUE) {
  # Almost all uses are relative to destination, except for rmarkdown templates
  full_path <- path_abs(path, start = pkg$dst_path)

  if (check && !made_by_pkgdown(full_path)) {
    if (!quiet) {
      cli::cli_inform("Skipping {.file {path}}: not generated by pkgdown")
    }
    return(FALSE)
  }

  if (same_contents(full_path, contents)) {
    # touching the file to update its modification time
    # which is important for proper lazy behavior
    fs::file_touch(full_path)
    return(FALSE)
  }

  if (!quiet) {
    writing_file(path_rel(full_path, pkg$dst_path), path)
  }

  write_lines(contents, path = full_path)
  TRUE
}

same_contents <- function(path, contents) {
  if (!file_exists(path))
    return(FALSE)

  new_hash <- digest::digest(contents, serialize = FALSE)

  cur_contents <- paste0(read_lines(path), collapse = "\n")
  cur_hash <-  digest::digest(cur_contents, serialize = FALSE)

  identical(new_hash, cur_hash)
}

file_digest <- function(path) {
  if (file_exists(path)) {
    digest::digest(file = path, algo = "xxhash64")
  } else {
    "MISSING"
  }
}


made_by_pkgdown <- function(path) {
  if (!file_exists(path)) return(TRUE)

  first <- paste(read_lines(path, n = 2), collapse = "\n")
  check_made_by(first)
}

check_made_by <- function(first) {
  if (length(first) == 0L) return(FALSE)
  grepl("<!-- Generated by pkgdown", first, fixed = TRUE)
}
