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

  data$logo <- list(src = logo_path(pkg, depth = depth))

  data <- utils::modifyList(data, data_template(pkg, depth = depth))
  data$pkgdown <- list(
    version = utils::packageDescription("pkgdown", fields = "Version")
  )
  data$has_favicons <- has_favicons(pkg)
  data$opengraph <- utils::modifyList(data_open_graph(pkg), data$opengraph %||% list())

  data$footer <- pkgdown_footer(data, pkg)

  # Dependencies for head
  if (pkg$bs_version > 3) {
    data$headdeps <- data_deps(pkg = pkg, depth = depth)
  }

  # Potential opt-out of syntax highlighting CSS
  data$needs_highlight_css <- !isFALSE(pkg$meta[["template"]]$params$highlightcss)

  # Search index location
  data$`search-index` <- paste0("/", pkg$prefix, "search.json")

  # render template components
  pieces <- c(
    "head", "navbar", "header", "content", "docsearch", "footer",
    "in-header", "after-head", "before-body", "after-body"
  )

  if (pkg$bs_version > 3) {
    pieces <- pieces[pieces != "docsearch"]
  }

  templates <- purrr::map_chr(
    pieces, find_template, name,
    template_path = template_path(pkg),
    bs_version = pkg$bs_version
  )
  components <- purrr::map(templates, render_template, data = data)
  components <- purrr::set_names(components, pieces)
  components$template <- name

  # render complete layout
  template <- find_template(
    "layout", name,
    template_path = template_path(pkg),
    bs_version = pkg$bs_version
  )
  rendered <- render_template(template, components)

  # footnotes
  if (pkg$bs_version > 3) {
    html <- xml2::read_html(rendered)
    tweak_footnotes(html)
    rendered <- as.character(html, options = character())
  }

  # navbar activation
  if (pkg$bs_version > 3) {
    html <- xml2::read_html(rendered)
    activate_navbar(html, data$output_file %||% path, pkg)
    rendered <- as.character(html, options = character())
  }

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
      authors = authors
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
    abort(paste("`opengraph` must be a list, not", friendly_type_of(og)))
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
  } else if (is.null(template$package)) {
    default_template_path <- file.path(pkg$src_path, "pkgdown", "templates")
    if (dir.exists(default_template_path)) {
      default_template_path
    } else {
      character()
    }
  } else {
    path_package_pkgdown(
      template$package,
      bs_version = pkg$bs_version,
      "templates"
    )
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

data_deps <- function(pkg, depth) {

  rlang::check_installed("htmltools")

  # theme variables from configuration
  bs_version <- pkg$bs_version
  bootswatch_theme <- pkg$meta[["template"]]$bootswatch %||%
    pkg$meta[["template"]]$params$bootswatch %||%
    NULL

  check_bootswatch_theme(bootswatch_theme, bs_version, pkg)

  bs_theme <- do.call(
    bslib::bs_theme,
    c(
      list(
        version = bs_version,
        bootswatch = bootswatch_theme
      ),
      utils::modifyList(
        pkgdown_bslib_defaults(),
        pkg$meta[["template"]]$bslib %||% list()
      )
    )
  )

  # map either secondary OR fg, bg to component-active-bg
  # and also dropdown-link-active-bg
  # unless a value was set by the user
  if (!is.null(pkg$meta[["template"]]$bslib$secondary)) {
    if (is.null(pkg$meta[["template"]]$bslib$`component-active-bg`)) {
      bs_theme <- bslib::bs_add_variables(
        bs_theme,
        "component-active-bg" = as.character(
          bslib::bs_get_variables(bs_theme, "secondary")
        )
      )
    }
  } else {
    if (is.null(pkg$meta[["template"]]$bslib$`component-active-bg`)) {
      bs_theme <- bslib::bs_add_variables(
        bs_theme,
        "component-active-bg" = "mix($body-color, $body-bg, 5%)",
        .where = "declarations"
      )
      if (is.null(pkg$meta[["template"]]$bslib$`dropdown-link-active-bg`)) {
        bs_theme <- bslib::bs_add_variables(
          bs_theme,
          "dropdown-link-active-bg" = "mix($body-color, $body-bg, 5%)",
          .where = "declarations"
        )
      }
    }
  }

  # map body color to navbar colors
  if (is.null(pkg$meta[["template"]]$bslib$`navbar-light-color`)) {
    bs_theme <- bslib::bs_add_variables(
      bs_theme,
      "navbar-light-color" = "rgba($body-color, 0.8)",
      .where = "declarations"
    )
  }
  if (is.null(pkg$meta[["template"]]$bslib$`navbar-light-hover-color`)) {
    bs_theme <- bslib::bs_add_variables(
      bs_theme,
      "navbar-light-hover-color" = "rgba($body-color, 0.9)",
      .where = "declarations"
    )
  }

  # map primary if set, or fg otherwise
  # to navbar-light-active-color + component-active-color
  # unless a value was set by the user
  default_prim_color <- if (!is.null(pkg$meta[["template"]][["bslib"]][["primary"]])) {
    pkg$meta[["template"]][["bslib"]][["primary"]]
  } else {
    as.character(bslib::bs_get_variables(bs_theme, "fg"))
  }
  if (is.null(pkg$meta[["template"]]$bslib$`navbar-light-active-color`)) {
    bs_theme <- bslib::bs_add_variables(
      bs_theme,
      "navbar-light-active-color" = default_prim_color
    )
  }
  if (is.null(pkg$meta[["template"]]$bslib$`component-active-color`)) {
    bs_theme <- bslib::bs_add_variables(
      bs_theme,
      "component-active-color" = default_prim_color
    )
  }

  # Map body-color to headings color
  if (is.null(pkg$meta[["template"]]$bslib$`headings-color`)) {
    bs_theme <- bslib::bs_add_variables(
      bs_theme,
      "headings-color" = as.character(bslib::bs_get_variables(bs_theme, "fg"))
    )
  }

  # map component-active-color to dropdown-link-active-color
  if (is.null(pkg$meta[["template"]]$bslib$`dropdown-link-active-color`)) {
    bs_theme <- bslib::bs_add_variables(
      bs_theme,
      "dropdown-link-active-color" = "$component-active-color",
      .where = "declarations"
    )
  }

  # map primary, fg, bg to dropdown hover/focus
  if (is.null(pkg$meta[["template"]]$bslib$`dropdown-link-hover-color`)) {
    bs_theme <- bslib::bs_add_variables(
      bs_theme,
      "dropdown-link-hover-color" = default_prim_color
    )
  }
  if (is.null(pkg$meta[["template"]]$bslib$`dropdown-link-hover-bg`)) {
    bs_theme <- bslib::bs_add_variables(
      bs_theme,
      "dropdown-link-hover-bg" = "mix($body-color, $body-bg, 5%)",
      .where = "declarations"
    )
  }

  if (is.null(pkg$meta[["template"]]$bslib$`border-color`)) {
    bs_theme <- bslib::bs_add_variables(
      bs_theme,
      "border-color" = "mix($body-color, $body-bg, 20%)",
      .where = "declarations"
    )
  }

  # pkgdown sass
  pkgdown_sass <- path_pkgdown("css", paste0("BS", bs_version), "pkgdown.sass")
  code_sass <- path_pkgdown("css", paste0("BS", bs_version), "syntax-highlighting.sass")
  all_sass <- paste(c(read_lines(pkgdown_sass), read_lines(code_sass)), collapse = "")
  pkgdown_css <- sass::sass_partial(all_sass, bs_theme)
  bs_theme <- bslib::bs_add_rules(bs_theme, pkgdown_css)

  deps <- bslib::bs_theme_dependencies(bs_theme, sass::sass_options_get(output_style = "expanded"))
  # Add other dependencies - TODO: more of those?
  # Even font awesome had a too old version in R Markdown (no ORCID)

  # Dependencies files end up at the website root in a deps folder
  deps <- lapply(
    deps,
    htmltools::copyDependencyToDir,
    file.path(pkg$dst_path, "deps")
  )

  # Function needed for indicating where that deps folder is compared to here
  transform_path <- function(x) {

    # At the time this function is called
    # html::renderDependencies() has already encoded x
    # with the default htmltools::urlEncodePath()
    x <- sub(htmltools::urlEncodePath(pkg$dst_path), "", x)

    if (depth == 0) {
      return(sub("/", "", x))
    }

    paste0(
      paste0(rep("..", depth), collapse = "/"), # as many levels up as depth
      x
    )

  }


  # Tags ready to be added in heads
  htmltools::renderDependencies(
    deps,
    srcType = "file",
    hrefFilter = transform_path
  )
}

check_bootswatch_theme <- function(bootswatch_theme, bs_version, pkg) {
  if (is.null(bootswatch_theme)) {
    return(invisible())
  }

  if (bootswatch_theme %in% bslib::bootswatch_themes(bs_version)) {
    return(invisible())
  }

  abort(
    sprintf(
      "Can't find Bootswatch theme '%s' (%s) for Bootstrap version '%s' (%s).",
      bootswatch_theme,
      pkgdown_field(pkg = pkg, "template", "bootswatch"),
      bs_version,
      pkgdown_field(pkg = pkg, "template", "bootstrap")
    )
  )
}

pkgdown_bslib_defaults <- function() {
  list(
    `navbar-nav-link-padding-x` = "1rem",
    `primary` = "#0054AD",
    `secondary` = "#e9ecef",
    `navbar-bg` = "#f8f9fa",
    `border-width` = "1px",
    `code-bg` = "#f8f8f8",
    `code-color` = "#333",
    `fu-color` = "#4758AB",
    `border-radius` = "1rem"
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
