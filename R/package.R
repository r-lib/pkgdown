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
  if (is_pkgdown(pkg)) {
    return(pkg)
  }

  if (!dir_exists(pkg)) {
    stop("`pkg` is not an existing directory", call. = FALSE)
  }

  desc <- read_desc(pkg)
  meta <- read_meta(pkg)
  meta <- utils::modifyList(meta, override)

  template_config <- find_template_config(
    package = meta$template$package,
    bs_version = meta$template$bootstrap
  )
  meta <- modify_list(template_config, meta)

  # Ensure the URL has no trailing slash
  if (!is.null(meta[["url"]])) {
    meta[["url"]] <- sub("/$", "", meta[["url"]])
  }

  package <- desc$get("Package")[[1]]
  version <- desc$get_field("Version")

  bs_version <- check_bootstrap_version(meta$template$bootstrap, pkg)

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
    stop("Can't find DESCRIPTION", call. = FALSE)
  }
  desc::description$new(path)
}

check_bootstrap_version <- function(version, pkg = list()) {
  if (is.null(version)) {
    3
  } else if (version %in% c(3, 5)) {
    version
  } else if (version == 4) {
    warn("`bootstrap: 4` no longer supported; using `bootstrap: 5` instead")
    5
  } else {
    abort(c(
      "Boostrap version must be 3 or 5.",
      x = sprintf(
        "You specified a value of %s in %s.",
        version,
        pkgdown_field(pkg, c("template", "bootstrap"))
      )
    ))
  }
}

# Metadata ----------------------------------------------------------------

pkgdown_config_path <- function(path) {
  path_first_existing(
    path,
    c("_pkgdown.yml",
      "_pkgdown.yaml",
      "pkgdown/_pkgdown.yml",
      "inst/_pkgdown.yml"
    )
  )
}

read_meta <- function(path) {
  path <- pkgdown_config_path(path)

  if (is.null(path)) {
    yaml <- list()
  } else {
    yaml <- yaml::yaml.load_file(path) %||% list()
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

  file_out <- gsub("\\.Rd$", ".html", file_in)
  file_out[file_out == "index.html"] <- "index-topic.html"

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
    str_trim()
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
    vig_path <- dir_ls(base, regexp = "\\.[rR]md$", type = "file", recurse = TRUE)
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

  tibble::tibble(
    name = path_ext_remove(vig_path),
    file_in = file_in,
    file_out = file_out,
    title = title,
    description = desc,
    depth = dir_depth(file_out)
  )
}

find_template_config <- function(package, bs_version = NULL) {
  if (is.null(package)) {
    return(list())
  }

  config <- path_package_pkgdown(
    "_pkgdown.yml",
    package = package,
    bs_version = bs_version
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
    sprintf("%s both create %s", src_files, dst_path(f_out))
  })
  names(same_out_bullets) <- rep_len("x", length(same_out_bullets))

  rlang::abort(c(
    "Rendered articles must have unique names. Rename or relocate one of the following source files:",
    same_out_bullets
  ))
}
