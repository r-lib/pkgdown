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
#'   If `""` (the default), prints to standard out.
#' @param depth Depth of path relative to base directory.
#' @param quiet If `quiet`, will suppress output messages
#' @export
render_page <- function(pkg = ".", name, data, path = "", depth = NULL, quiet = FALSE) {
  pkg <- as_pkgdown(pkg)

  if (is.null(depth)) {
    depth <- length(strsplit(path, "/")[[1]]) - 1L
  }

  data <- utils::modifyList(data, data_template(pkg, depth = depth))
  data$pkgdown <- list(
    version = utils::packageDescription("pkgdown", fields = "Version")
  )
  data$has_favicons <- has_favicons(pkg)
  data$opengraph <- utils::modifyList(data_open_graph(pkg), data$opengraph %||% list())

  # The real location of 404.html is dynamic (#1129).
  # Relative root does not work, use the full URL if available.
  if (path == "404.html" && length(pkg$meta$url)) {
    data$site$root <- paste0(pkg$meta$url, "/")
  }

  data$footer <- pkgdown_footer(data, pkg)

  # render template components
  pieces <- c(
    "head", "navbar", "header", "content", "docsearch", "footer",
    "in-header", "after-head", "before-body", "after-body"
  )

  templates <- purrr::map_chr(
    pieces, find_template, name,
    template_path = template_path(pkg),
    bs_version = get_bs_version(pkg)
  )
  components <- purrr::map(templates, render_template, data = data)
  components <- purrr::set_names(components, pieces)
  components$template <- name

  if (path == "404.html" && !is.null(pkg$meta$url)) {
    components$navbar <- tweak_navbar_links(components$navbar, pkg = pkg)
  }

  # render complete layout
  template <- find_template(
    "layout", name,
    template_path = template_path(pkg),
    bs_version = get_bs_version(pkg)
  )
  rendered <- render_template(template, components)
  write_if_different(pkg, rendered, path, quiet = quiet)
}

#' @export
#' @rdname render_page
data_template <- function(pkg = ".", depth = 0L) {
  pkg <- as_pkgdown(pkg)

  roles <- pkg$meta$authors$footer$roles %||% default_roles()
  authors <- data_authors(pkg, roles = roles)$main %>%
    purrr::map_chr("name") %>%
    paste(collapse = ", ")

  # Force inclusion so you can reliably refer to objects inside yaml
  # in the mustache templates
  yaml <- purrr::pluck(pkg, "meta", "template", "params", .default = list())
  yaml$.present <- TRUE

  # Look for extra assets to add
  extra <- list()
  extra$css <- path_first_existing(pkg$src_path, "pkgdown", "extra.css")
  extra$js <- path_first_existing(pkg$src_path, "pkgdown", "extra.js")

  print_yaml(list(
    year = strftime(Sys.time(), "%Y"),
    package = list(
      name = pkg$package,
      version = as.character(pkg$version),
      authors = authors,
      logo = logo_path(pkg, depth)
    ),
    development = pkg$development,
    site = list(
      root = up_path(depth),
      title = pkg$meta$title %||% pkg$package
    ),
    dev = pkg$use_dev,
    extra = extra,
    navbar = data_navbar(pkg, depth = depth),
    yaml = yaml
  ))
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
    abort(paste("`opengraph` must be a list, not", friendly_type(typeof(og))))
  }
  supported_fields <- c("image", "twitter")
  unsupported_fields <- setdiff(names(og), supported_fields)
  if (length(unsupported_fields)) {
    warn(paste0(
      "Unsupported `opengraph` ",
      ngettext(length(unsupported_fields), "field", "fields"), ": ",
      paste(unsupported_fields, collapse = ", ")
    ))
  }
  if ("twitter" %in% names(og)) {
    if (is.character(og$twitter) && length(og$twitter) == 1 && grepl("^@", og$twitter)) {
      abort(paste(
        "The `opengraph: twitter` option must be a list. Did you mean this?",
        "opengraph:",
        "  twitter:",
        paste("    creator:", og$twitter),
        sep = "\n"
      ))
    }
    if (!is.list(og$twitter)) {
      abort("The `opengraph: twitter` option must be a list.")
    }
    if (is.null(og$twitter$creator) && is.null(og$twitter$site)) {
      abort(
        "The `opengraph: twitter` option must include either 'creator' or 'site'."
      )
    }
  }
  if ("image" %in% names(og)) {
    if (is.character(og$image) && length(og$image) == 1) {
      abort(paste(
        "The `opengraph: image` option must be a list. Did you mean this?",
        "opengraph",
        "  image:",
        paste("    src:", og$image),
        sep = "\n"
      ))
    }
    if (!is.list(og$image)) {
      abort("The `opengraph: image` option must be a list.")
    }
  }
  og[intersect(supported_fields, names(og))]
}

get_bs_version <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  template <- pkg$meta[["template"]]

  if (is.null(template$bootstrap)) {
    return(3)
  }
  if (template$bootstrap %in% c(3, 4)) {
    return(template$bootstrap)
  }

  abort(
    message = c(
      "Boostrap version must be 3 or 4.",
      x = sprintf(
        "You specified a value of %s in %s.",
        template$bootstrap,
        pkgdown_field(pkg = pkg, "template", "bootstrap")
      )
    )
  )

}

template_path <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  template <- pkg$meta[["template"]]

  if (!is.null(template$path)) {
    path <- path_abs(template$path, start = pkg$src_path)

    if (!file_exists(path))
      abort(paste0("Can not find template path ", src_path(path)))

    path
  } else if (!is.null(template$package)) {
    path_package_pkgdown(
      template$package,
      bs_version = get_bs_version(pkg),
      "templates"
    )
  } else {
    character()
  }
}

render_template <- function(path, data) {
  template <- read_file(path)
  if (length(template) == 0)
    return("")

  whisker::whisker.render(template, data)
}

find_template <- function(type, name, ext = ".html", template_path = NULL,
                          bs_version) {
  paths <- c(
    template_path,
    path_pkgdown("templates", paste0("BS", bs_version))
  )
  names <- c(
    paste0(type, "-", name, ext),
    paste0(type, ext)
  )
  all <- expand.grid(path = paths, name = names)
  locations <- path(all$path, all$name)

  Find(file_exists, locations, nomatch =
       stop("Can't find template for ", type, "-", name, ".", call. = FALSE))
}


write_if_different <- function(pkg, contents, path, quiet = FALSE, check = TRUE) {
  # Almost all uses are relative to destination, except for rmarkdown templates
  full_path <- path_abs(path, start = pkg$dst_path)

  if (check && !made_by_pkgdown(full_path)) {
    if (!quiet) {
      message("Skipping '", path, "': not generated by pkgdown")
    }
    return(FALSE)
  }

  if (same_contents(full_path, contents)) {
    return(FALSE)
  }

  if (!quiet) {
    cat_line("Writing ", dst_path(path))
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

pkgdown_footer <- function(data, pkg) {

  footer_components <- list(
    authors = footer_authors(data, pkg),
    pkgdown = footer_pkgdown(data)
  )

  # footer left
  left_structure <- pkg$meta$footer$left$structure %||% c("authors")

  left_components <- modify_list(
    footer_components,
    pkg$meta$footer$left$components
  )

  check_components(
    needed = left_structure,
    present = names(left_components),
    where = c("footer", "left", "components"),
    pkg = pkg
  )

  left_final_components <- markdown_block(
    paste0(left_components[left_structure], collapse = " "),
    pkg = pkg
  )

  # footer right
  right_structure <- pkg$meta$footer$right$structure %||% c("pkgdown")

  right_components <- modify_list(
    footer_components,
    pkg$meta$footer$right$components
  )

  check_components(
    needed = right_structure,
    present = names(right_components),
    where = c("footer", "right", "components"),
    pkg = pkg
  )

  right_final_components <- markdown_block(
    paste0(right_components[right_structure], collapse = " "),
    pkg = pkg
  )

  list(left = left_final_components, right = right_final_components)
}

footer_authors <- function(data, pkg) {
  text <- pkg$meta$authors$footer$text %||% "Developed by"
  paste0(trimws(text), " ", data$package$authors, ".")
}

footer_pkgdown <- function(data) {
  paste0(
    'Site built with <a href="https://pkgdown.r-lib.org/">pkgdown</a> ',
    data$pkgdown$version, "."
  )
}

logo_path <- function(pkg, depth) {
  if (!has_logo(pkg)) {
    return(NULL)
  }
 path <- "package-logo.png"

  if (depth == 0) {
    return(path)
  }

  paste0(
    paste0(rep("..", depth), collapse = "/"), # as many levels up as depth
    "/",
    path
  )
}
