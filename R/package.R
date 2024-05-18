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
    cli::cli_abort("{.arg override} must be a list, not {obj_type_friendly(override)}.")
  }

  if (is_pkgdown(pkg)) {
    pkg$meta <- modify_list(pkg$meta, override)
    return(pkg)
  }

  check_string(pkg)
  if (!dir_exists(pkg)) {
    cli::cli_abort("{.file {pkg}} is not an existing directory")
  }

  desc <- read_desc(pkg)
  meta <- read_meta(pkg)
  meta <- modify_list(meta, override)

  # A local Bootstrap version, when provided, may drive the template choice
  bs_version_local <- get_bootstrap_version(
    template = meta$template,
    pkg = list(src_path = pkg)
  )

  template_config <- find_template_config(
    package = meta$template$package,
    bs_version = bs_version_local
  )

  bs_version_template <-
    if (is.null(bs_version_local)) {
      get_bootstrap_version(
        template = template_config$template,
        pkg = list(src_path = pkg),
        package = meta$template$package
      )
    }

  meta <- modify_list(template_config, meta)

  # Ensure the URL has no trailing slash
  if (!is.null(meta[["url"]])) {
    meta[["url"]] <- sub("/$", "", meta[["url"]])
  }

  package <- desc$get_field("Package")
  version <- desc$get_field("Version")

  # Check the final Bootstrap version, possibly filled in by template pkg
  bs_version <- check_bootstrap_version(
    bs_version_local %||% bs_version_template,
    pkg = list(src_path = pkg)
  )

  development <- meta_development(meta, version, bs_version)

  if (is.null(meta$destination)) {
    dst_path <- path(pkg, "docs")
  } else {
    dst_path <- path_abs(meta$destination, start = pkg)
  }

  if (development$in_dev) {
    dst_path <- path(dst_path, development$destination)
  }

  install_metadata <- meta$deploy$install_metadata %||% FALSE

  pkg_list <- list(
      package = package,
      version = version,
      lang = meta$lang %||% "en",

      src_path = path_abs(pkg),
      dst_path = path_abs(dst_path),
      install_metadata = install_metadata,

      desc = desc,
      meta = meta,
      figures = meta_figures(meta),
      repo = package_repo(desc, meta),

      development = development,
      topics = package_topics(pkg, package),
      tutorials = package_tutorials(pkg, meta),
      vignettes = package_vignettes(pkg),
      bs_version = bs_version
    )
  pkg_list$prefix <- ""
  if (pkg_list$development$in_dev) {
    pkg_list$prefix <- paste0(
      meta_development(pkg_list$meta, pkg_list$version)$destination,
      "/"
    )
  }

  structure(
    pkg_list,
    class = "pkgdown"
  )
}

is_pkgdown <- function(x) inherits(x, "pkgdown")

read_desc <- function(path = ".") {
  path <- path(path, "DESCRIPTION")
  if (!file_exists(path)) {
    cli::cli_abort("Can't find {.file DESCRIPTION}", call = caller_env())
  }
  desc::description$new(path)
}

get_bootstrap_version <- function(template, package = NULL, pkg) {
  if (is.null(template)) {
    return(NULL)
  }

  template_bootstrap <- template[["bootstrap"]]
  template_bslib <- template[["bslib"]][["version"]]

  if (!is.null(template_bootstrap) && !is.null(template_bslib)) {
    if (!is.null(package)) {
      hint <- "Specified locally and in template package {.pkg {package}}."
    } else {
      hint <- NULL
    }

    config_abort(
      pkg,
      c(
        "Must set one only of {.field template.bootstrap} and {.field template.bslib.version}.",
        i = hint
      ),
      call = caller_env()
    )
  }

  template_bootstrap %||% template_bslib
}

check_bootstrap_version <- function(version, pkg) {
  if (is.null(version)) {
    3
  } else if (version %in% c(3, 5)) {
    version
  } else if (version == 4) {
    cli::cli_warn("{.var bootstrap: 4} no longer supported, using {.var bootstrap: 5} instead")
    5
  } else {
    config_abort(
      pkg,
      "{.field template.bootstrap} must be 3 or 5, not {.val {version}}.",
      call = caller_env()
    )
  }
}

# Metadata ----------------------------------------------------------------

pkgdown_config_path <- function(path) {
  path_first_existing(
    path,
    c(
      "_pkgdown.yml", "_pkgdown.yaml",
      "pkgdown/_pkgdown.yml", "pkgdown/_pkgdown.yaml",
      "inst/_pkgdown.yml", "inst/_pkgdown.yaml"
    )
  )
}

read_meta <- function(path, check_path = TRUE) {
  if (check_path) {
    # check_path = FALSE can be used to supply a direct path to
    # read_meta instead of a pkgdown object.
    path <- pkgdown_config_path(path)
  }

  # If parsing fails, it will say Error in read_meta()
  call <- current_env()
  if (is.null(path)) {
    yaml <- list()
  } else {
    yaml <- withCallingHandlers(
      yaml::yaml.load_file(path),
      error = function(e) {
        yaml_error_msg <- conditionMessage(e)
        # Create a clickable path, in case we end up
        # just rethrowing the original message
        yaml_error_msg <- gsub(
          "\\(([^\\)]+)\\)",
          "({.path \\1})",
          yaml_error_msg
        )

        # trying to extract the parsing error type?
        # like block mapping, block collection?
        what <- regmatches(
          yaml_error_msg,
          m = regexpr("block\\s[[:alpha:]]+", yaml_error_msg)
        )
        # search for all occurences of digits (1 to 4 digits long)
        # I would not see a _pkgdown.yml file containing >9999 lines.
        error_locations <- regmatches(
          yaml_error_msg,
          m = gregexpr("\\d{1,4}", yaml_error_msg)
        )
        error_locations <- unlist(error_locations, use.names = FALSE)
        if (length(error_locations) != 4 || !is_string(what)) {
          # can't parse the error message properly,
          # just rethrow it cli style
          cli::cli_abort(yaml_error_msg, call = call)
        }
        # yaml throws its message like this:
        # ! (./pkgdown/_pkgdown.yml) Parser error: while parsing
        # a block mapping at line 1, column 1
        # did not find expected key at line 9, column 3
        block_line <- error_locations[1]
        block_col <- error_locations[2]
        error_line <- error_locations[3]
        error_col <- error_locations[4]

        # try to identify the faulty block / field name to add a hint
        # i.e. the block at where the parser gives his first error.
        # but it may be more accurate to try to detect a field / block
        # looking backward from the second position mentioned in the error.
        block_name <- withCallingHandlers(
          read_lines(path, n = block_line),
          error = function(e) NULL
        )
        if (!is.null(block_name)) {
          block_name <- block_name[length(block_name)]
          block_name <- gsub(":.*$", ":", block_name)
        }

        block_pos <- cli::style_hyperlink(
          paste0(block_line),
          url = paste0("file://", path),
          params = list(
            line = as.integer(block_line),
            col = as.integer(block_col)
          )
        )
        error_pos <- cli::style_hyperlink(
          paste0(error_line),
          url = paste0("file://", path),
          params = list(
            line = as.integer(error_line),
            col = as.integer(error_col)
          )
        )
        cli::cli_abort(
          c(
            "!" = "The {.field {block_name}} field failed to parse.",
            "i" = "Error occured between lines {block_pos} and {error_pos}.",
            "i" = "Edit {.path {path}} to fix the problem.",
            # repeat the yaml error
            "i" = "Did not find the expected keys at line {error_pos} while parsing a {what}."
          ),
          call = call,
          parent = e
        )
      }
    )
    yaml <- yaml %||% list()
  }

  yaml
}

# Topics ------------------------------------------------------------------

package_topics <- function(path = ".", package = "pkgdown") {
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
    internal = internal
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
  x %>%
    purrr::keep(inherits, tag) %>%
    purrr::map_chr(c(1, 1))
}

extract_title <- function(x) {
  x %>%
    purrr::detect(inherits, "tag_title") %>%
    flatten_text(auto_link = FALSE) %>%
    str_squish()
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

# Vignettes ---------------------------------------------------------------

package_vignettes <- function(path = ".") {
  base <- path(path, "vignettes")

  if (!dir_exists(base)) {
    vig_path <- character()
  } else {
    vig_path <- dir_ls(base, regexp = "\\.[Rrq]md$", type = "file", recurse = TRUE)
  }

  vig_path <- path_rel(vig_path, base)
  vig_path <- vig_path[!grepl("^_", path_file(vig_path))]
  vig_path <- vig_path[!grepl("^tutorials", path_dir(vig_path))]

  yaml <- purrr::map(path(base, vig_path), rmarkdown::yaml_front_matter)
  title <- purrr::map_chr(yaml, list("title", 1), .default = "UNKNOWN TITLE")
  desc <- purrr::map_chr(yaml, list("description", 1), .default = NA_character_)
  ext <- purrr::map_chr(yaml, c("pkgdown", "extension"), .default = "html")
  title[ext == "pdf"] <- paste0(title[ext == "pdf"], " (PDF)")

  # Vignettes will be written to /articles/ with path relative to vignettes/
  # *except* for vignettes in vignettes/articles, which are moved up a level
  file_in <- path("vignettes", vig_path)
  file_out <- path_ext_set(vig_path, ext)
  file_out[!path_has_parent(file_out, "articles")] <- path(
    "articles", file_out[!path_has_parent(file_out, "articles")]
  )
  check_unique_article_paths(file_in, file_out)

  out <- tibble::tibble(
    name = path_ext_remove(vig_path),
    file_in = file_in,
    file_out = file_out,
    title = title,
    description = desc,
    depth = dir_depth(file_out)
  )
  out[order(path_file(out$file_out)), ]
}

find_template_config <- function(package,
                                 bs_version = NULL,
                                 error_call = caller_env()) {
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
