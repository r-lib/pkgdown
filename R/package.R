#' Generate pkgdown data structure
#'
#' You will generally not need to use this unless you need a custom site
#' design and you're writing your own equivalent of [build_site()].
#'
#' @param pkg Path to package.
#' @param override An optional named list used to temporarily override
#'   values in `_pkgdown.yml`
#' @export
as_pkgdown <- function(pkg = ".", override = list()) {
  if (!is.list(override)) {
    cli::cli_abort(
      "{.arg override} must be a list, not {obj_type_friendly(override)}."
    )
  }

  if (is_pkgdown(pkg)) {
    pkg$meta <- modify_list(pkg$meta, override)
    return(pkg)
  }

  check_string(pkg)
  if (!dir_exists(pkg)) {
    if (dir.exists(pkg)) {
      #nolint
      # path expansion with fs and base R is different on Windows.
      # By default "~/", is typically C:/Users/username/Documents, while fs see "~/" as C:/Users/username, to be more platform portable.
      # Read more in ?fs::path_expand
      cli::cli_abort(
        "pkgdown accepts {.href [fs paths](https://fs.r-lib.org/reference/path_expand.html#details)}."
      )
    }
    cli::cli_abort("{.file {pkg}} is not an existing directory")
  }

  if (!dir.exists(pkg)) {
    #nolint
    # Use complete path if fs path doesn't exist according to base R #2639
    pkg <- path_expand(pkg)
  }

  src_path <- pkg

  desc <- read_desc(src_path)
  meta <- read_meta(src_path)
  meta <- modify_list(meta, override)

  # Create a partial pkgdown object so we can use config_pluck_* functions
  pkg <- list(
    package = desc$get_field("Package"),
    version = desc$get_field("Version"),
    src_path = path_abs(src_path),

    meta = meta,
    desc = desc
  )
  class(pkg) <- "pkgdown"

  # If boostrap version set locally, it drives the template choice
  # But if it's not set locally, the template may have a default
  template <- config_pluck_list(pkg, "template")
  template_package <- config_pluck_string(pkg, "template.package")

  bs_version_local <- get_bootstrap_version(pkg, pkg$meta$template)
  template_meta <- find_template_config(template_package, bs_version_local)

  if (is.null(bs_version_local)) {
    bs_version_remote <- get_bootstrap_version(
      pkg,
      template_meta$template,
      template_package
    )
  } else {
    bs_version_remote <- NULL
  }
  bs_version <- bs_version_local %||% bs_version_remote %||% 3
  check_bootstrap_version(bs_version, error_pkg = pkg)
  pkg$bs_version <- bs_version

  pkg$meta <- modify_list(template_meta, pkg$meta)

  # Ensure the URL has no trailing slash
  if (!is.null(pkg$meta$url)) {
    pkg$meta$url <- sub("/$", "", pkg$meta$url)
  }

  pkg$development <- meta_development(pkg)
  pkg$prefix <- pkg$development$prefix

  dest <- config_pluck_string(pkg, "destination")
  pkg$dst_path <- path_abs(dest %||% "docs", start = src_path)
  if (pkg$development$in_dev) {
    pkg$dst_path <- path(pkg$dst_path, pkg$development$destination)
  }

  pkg$lang <- get_pkg_lang(pkg)
  pkg$install_metadata <- config_pluck_bool(
    pkg,
    "deploy.install_metadata",
    FALSE
  )
  pkg$figures <- meta_figures(pkg)
  pkg$repo <- package_repo(pkg)
  pkg$topics <- package_topics(src_path)
  pkg$tutorials <- package_tutorials(src_path, meta)
  pkg$vignettes <- package_vignettes(src_path)

  pkg
}

is_pkgdown <- function(x) inherits(x, "pkgdown")

read_desc <- function(path = ".") {
  path <- path(path, "DESCRIPTION")
  if (!file_exists(path)) {
    cli::cli_abort("Can't find {.file DESCRIPTION}", call = caller_env())
  }
  desc::description$new(path)
}

get_pkg_lang <- function(pkg) {
  if (!is.null(pkg$meta$lang)) {
    return(pkg$meta$lang)
  }

  if (pkg$desc$has_fields("Language")) {
    field <- pkg$desc$get_field("Language")
    if (length(field) && nchar(field) > 0) {
      return(regmatches(field, regexpr("[^,]+", field)))
    }
  }

  return("en")
}

get_bootstrap_version <- function(
  pkg,
  template,
  template_package = NULL,
  call = caller_env()
) {
  if (is.null(template)) {
    return(NULL)
  }

  template_bootstrap <- template[["bootstrap"]]
  template_bslib <- template[["bslib"]][["version"]]

  if (!is.null(template_bootstrap) && !is.null(template_bslib)) {
    if (!is.null(template_package)) {
      hint <- "Specified locally and in template package {.pkg {template_package}}."
    } else {
      hint <- NULL
    }

    msg <- "must set only one of {.field template.bootstrap} and {.field template.bslib.version}."
    config_abort(pkg, c(msg, i = hint), call = call)
  }

  template_bootstrap %||% template_bslib
}

check_bootstrap_version <- function(
  version,
  error_pkg,
  error_call = caller_env()
) {
  if (version %in% c(3, 5)) {
    version
  } else if (version == 4) {
    msg <- c(
      "{.var template.bootstrap: 4} no longer supported",
      i = "Using {.var template.bootstrap: 5} instead"
    )
    config_warn(error_pkg, msg, call = error_call)
    5
  } else {
    msg <- "{.field template.bootstrap} must be 3 or 5, not {.val {version}}."
    config_abort(error_pkg, msg, error_call = caller_env())
  }
}

# Metadata ----------------------------------------------------------------

pkgdown_config_path <- function(path) {
  if (is_pkgdown(path)) {
    path <- path$src_path
  }

  path_first_existing(
    path,
    c(
      "_pkgdown.yml",
      "_pkgdown.yaml",
      "pkgdown/_pkgdown.yml",
      "pkgdown/_pkgdown.yaml",
      "inst/_pkgdown.yml",
      "inst/_pkgdown.yaml"
    )
  )
}

read_meta <- function(path, call = caller_env()) {
  path <- pkgdown_config_path(path)

  if (is.null(path)) {
    yaml <- list()
  } else {
    yaml <- withCallingHandlers(
      yaml::yaml.load_file(path, error.label = NULL) %||% list(),
      error = function(e) {
        cli::cli_abort(
          "Could not parse config file at {.path {path}}.",
          call = call,
          parent = e
        )
      }
    )
  }
  yaml
}

# Topics ------------------------------------------------------------------

package_topics <- function(path = ".") {
  # Needed if title contains sexpr
  local_context_eval()

  rd <- package_rd(path)

  aliases <- purrr::map(rd, extract_tag, "tag_alias")
  names <- purrr::map_chr(rd, extract_tag, "tag_name")
  titles <- purrr::map_chr(rd, extract_title)
  concepts <- unname(purrr::map(rd, extract_tag, "tag_concept"))
  keywords <- unname(purrr::map(rd, extract_tag, "tag_keyword"))
  internal <- purrr::map_lgl(keywords, ~ "internal" %in% .)
  source <- purrr::map(rd, extract_source)
  lifecycle <- unname(purrr::map(rd, extract_lifecycle))

  file_in <- names(rd)
  file_out <- rd_output_path(file_in)

  funs <- purrr::map(rd, topic_funs)

  tibble::tibble(
    name = names,
    file_in = file_in,
    file_out = file_out,
    alias = aliases,
    funs = funs,
    title = titles,
    rd = rd,
    source = source,
    keywords = keywords,
    concepts = concepts,
    internal = internal,
    lifecycle = lifecycle
  )
}

rd_output_path <- function(x) {
  x <- gsub("\\.Rd$", ".html", x)
  x[x == "index.html"] <- "index-topic.html"
  x
}

package_rd <- function(path = ".") {
  man_path <- path(path, "man")

  if (!dir_exists(man_path)) {
    return(set_names(list(), character()))
  }

  rd <- dir_ls(man_path, regexp = "\\.[Rr]d$", type = "file")
  names(rd) <- path_file(rd)
  lapply(rd, rd_file, pkg_path = path)
}

extract_tag <- function(x, tag) {
  purrr::map_chr(purrr::keep(x, inherits, tag), c(1, 1))
}

extract_title <- function(x) {
  title <- purrr::detect(x, inherits, "tag_title")
  str_squish(flatten_text(title, auto_link = FALSE))
}

extract_source <- function(x) {
  nl <- purrr::map_lgl(x, inherits, "TEXT") & x == "\n"
  comment <- purrr::map_lgl(x, inherits, "COMMENT")

  first_comment <- cumsum(!(nl | comment)) == 0
  lines <- as.character(x[first_comment])
  text <- paste0(lines, collapse = "")

  if (!grepl("roxygen2", text)) {
    return(character())
  }

  m <- gregexpr("R/[^ ]+\\.[rR]", text)
  regmatches(text, m)[[1]]
}

extract_lifecycle <- function(x) {
  desc <- purrr::keep(x, inherits, "tag_description")
  fig <- extract_figure(desc)

  if (!is.null(fig) && length(fig) > 0 && length(fig[[1]]) > 0) {
    path <- as.character(fig[[1]][[1]])
    if (grepl("lifecycle", path)) {
      name <- gsub("lifecycle-", "", path)
      name <- path_ext_remove(name)

      # Translate the most common lifecylce names
      name <- switch(
        name,
        deprecated = tr_("deprecated"),
        superseded = tr_("superseded"),
        experimental = tr_("experimental"),
        stable = tr_("stable"),
        name
      )

      return(name)
    }
  }
  NULL
}

extract_figure <- function(elements) {
  for (element in elements) {
    if (inherits(element, "tag_figure")) {
      return(element)
    } else if (inherits(element, "tag")) {
      child <- extract_figure(element)
      if (!is.null(child)) {
        return(child)
      }
    }
  }
  NULL
}

# Vignettes ---------------------------------------------------------------

package_vignettes <- function(path = ".") {
  base <- path(path, "vignettes")

  if (!dir_exists(base)) {
    vig_path <- character()
  } else {
    vig_path <- dir_ls(
      base,
      regexp = "\\.[Rrq]md$",
      type = "file",
      recurse = TRUE
    )
  }

  vig_path <- path_rel(vig_path, base)
  vig_path <- vig_path[!grepl("^_", path_file(vig_path))]
  vig_path <- vig_path[!grepl("^tutorials", path_dir(vig_path))]

  type <- tolower(path_ext(vig_path))

  meta <- purrr::map(path(base, vig_path), article_metadata)
  title <- purrr::map_chr(meta, "title")
  desc <- purrr::map_chr(meta, "desc")
  ext <- purrr::map_chr(meta, "ext")

  # Vignettes will be written to /articles/ with path relative to vignettes/
  # *except* for vignettes in vignettes/articles, which are moved up a level
  file_in <- path("vignettes", vig_path)
  file_out <- path_ext_set(vig_path, ext)
  file_out[!path_has_parent(file_out, "articles")] <- path(
    "articles",
    file_out[!path_has_parent(file_out, "articles")]
  )
  check_unique_article_paths(file_in, file_out)

  out <- tibble::tibble(
    name = as.character(path_ext_remove(vig_path)),
    type = type,
    file_in = as.character(file_in),
    file_out = as.character(file_out),
    title = title,
    description = desc,
    depth = dir_depth(file_out)
  )
  out[order(path_file(out$file_out)), ]
}

article_metadata <- function(path) {
  if (path_ext(path) == "qmd") {
    inspect <- quarto::quarto_inspect(path)
    meta <- inspect$formats[[1]]$metadata

    out <- list(
      title = meta$title %||% "UNKNOWN TITLE",
      desc = meta$description %||% NA_character_,
      ext = path_ext(inspect$formats[[1]]$pandoc$`output-file`) %||% "html"
    )
  } else {
    yaml <- rmarkdown::yaml_front_matter(path)
    out <- list(
      title = yaml$title[[1]] %||% "UNKNOWN TITLE",
      desc = yaml$description[[1]] %||% NA_character_,
      ext = yaml$pkgdown$extension %||% "html"
    )
  }

  if (out$ext == "pdf") {
    out$title <- paste0(out$title, " (PDF)")
  }

  out
}

find_template_config <- function(
  package,
  bs_version = NULL,
  error_call = caller_env()
) {
  if (is.null(package)) {
    return(list())
  }

  config <- path_package_pkgdown(
    "_pkgdown.yml",
    package,
    bs_version,
    error_call = error_call
  )
  if (!file_exists(config)) {
    return(list())
  }

  yaml::yaml.load_file(config) %||% list()
}

check_unique_article_paths <- function(file_in, file_out) {
  if (!any(duplicated(file_out))) {
    return()
  }
  # Since we move vignettes/articles/* up one level, we may end up with two
  # vignettes destined for the same final location. We also know that if there
  # are conflicting final paths, they are the result of exactly two source files

  file_out_dup <- file_out[duplicated(file_out)]

  same_out_bullets <- purrr::map_chr(file_out_dup, function(f_out) {
    src_files <- src_path(file_in[which(file_out == f_out)])
    src_files <- paste(src_files, collapse = " and ")
  })
  names(same_out_bullets) <- rep_len("x", length(same_out_bullets))

  cli::cli_abort(
    c(
      "Rendered articles must have unique names. Rename or relocate:",
      same_out_bullets
    ),
    call = caller_env()
  )
}
