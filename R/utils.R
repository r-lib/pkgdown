up_path <- function(depth) {
  paste(rep.int("../", depth), collapse = "")
}

dir_depth <- function(x) {
  # length(strsplit(path, "/")[[1]]) - 1L
  purrr::map_int(strsplit(x, ""), function(x) sum(x == "/"))
}

invert_index <- function(x) {
  stopifnot(is.list(x))

  if (length(x) == 0)
    return(list())

  key <- rep(names(x), purrr::map_int(x, length))
  val <- unlist(x, use.names = FALSE)

  split(key, val)
}

rstudio_save_all <- function() {
  if (is_installed("rstudioapi") && rstudioapi::hasFun("documentSaveAll")) {
    rstudioapi::documentSaveAll()
  }
}

is_syntactic <- function(x) x == make.names(x)

auto_quote <- function(x) {
  ifelse(is_syntactic(x), x, paste0("`", x, "`"))
}

str_trim <- function(x) gsub("^\\s+|\\s+$", "", x)

str_squish <- function(x) str_trim(gsub("\\s+", " ", x))

unwrap_purrr_error <- function(code) {
  withCallingHandlers(
    code,
    purrr_error_indexed = function(err) {
      cnd_signal(err$parent)
    }
  )
}

tr_ <- function(...) {
  enc2utf8(gettext(..., domain = "R-pkgdown"))
}

# devtools metadata -------------------------------------------------------

system_file <- function(..., package) {
  if (is.null(devtools_meta(package))) {
    path(system.file(package = package), ...)
  } else {
    path(getNamespaceInfo(package, "path"), "inst", ...)
  }
}

devtools_meta <- function(x) {
  ns <- .getNamespace(x)
  ns[[".__DEVTOOLS__"]]
}

# CLI ---------------------------------------------------------------------

dst_path <- cli::combine_ansi_styles(
  cli::style_bold, cli::col_cyan
)

src_path <- cli::combine_ansi_styles(
  cli::style_bold, cli::col_green
)

writing_file <- function(path, show) {
  path <- as.character(path)
  text <- dst_path(as.character(show))
  cli::cli_inform("Writing {.run [{text}](pkgdown::preview_site(path='{path}'))}")
}

has_internet <- function() {
  getOption("pkgdown.internet", default = TRUE)
}

modify_list <- function(x, y) {
  if (is.null(x)) {
    return(y)
  } else if (is.null(y)) {
    return(x)
  }

  utils::modifyList(x, y)
}

# from https://github.com/r-lib/rematch2/blob/8098bd06f251bfe0f20c0598d90fc20b741d13f8/R/package.R#L47
re_match <- function(text, pattern, perl = TRUE, ...) {

  stopifnot(is.character(pattern), length(pattern) == 1, !is.na(pattern))
  text <- as.character(text)

  match <- regexpr(pattern, text, perl = perl, ...)

  start  <- as.vector(match)
  length <- attr(match, "match.length")
  end    <- start + length - 1L

  matchstr <- substring(text, start, end)
  matchstr[ start == -1 ] <- NA_character_

  res <- data.frame(
    .text = text,
    .match = matchstr
  )

  if (!is.null(attr(match, "capture.start"))) {

    gstart  <- attr(match, "capture.start")
    glength <- attr(match, "capture.length")
    gend    <- gstart + glength - 1L

    groupstr <- substring(text, gstart, gend)
    groupstr[ gstart == -1 ] <- NA_character_
    dim(groupstr) <- dim(gstart)

    res <- cbind(groupstr, res)
  }

  names(res) <- c(attr(match, "capture.names"), ".text", ".match")
  class(res) <- c("tbl_df", "tbl", class(res))
  res
}

# external links can't be an active item
# external links start with http(s)
# but are NOT an absolute URL to the pkgdown site at hand
is_internal_link <- function(links, pkg) {
  if (is.null(pkg$meta$url)) {
    !grepl("https?://", links)
  } else {
    !grepl("https?://", links) | grepl(pkg$meta$url, links)
  }
}

ruler <- function(width = getOption("width")) {
  x <- seq_len(width)
  y <- rep("-", length(x))
  y[x %% 5 == 0] <- "+"
  y[x %% 10 == 0] <- (x[x%%10 == 0] %/% 10) %% 10
  cat(y, "\n", sep = "")
  cat(x %% 10, "\n", sep = "")
}

get_section_level <- function(section) {
  class <- xml2::xml_attr(section, "class")

level <- as.numeric(re_match(class, "level(\\d+)")[[1]])
  level[is.na(level)] <- 0
  level
}

section_id <- function(section) {
  h <- xml2::xml_find_first(section, ".//h1|.//h2|.//h3|.//h4|.//h5|.//h6")
  xml2::xml_attr(h, "id")
}

on_ci <- function() {
  isTRUE(as.logical(Sys.getenv("CI", "false")))
}

# yaml ------------------------------------------------------------

print_yaml <- function(x) {
  structure(x, class = "print_yaml")
}
#' @export
print.print_yaml <- function(x, ...) {
  cat(yaml::as.yaml(x), "\n", sep = "")
}

write_yaml <- function(x, path) {
  yaml::write_yaml(
    x,
    path,
    handlers = list(logical = yaml::verbatim_logical)
  )
}

# Helpers for testing -----------------------------------------------------

xpath_xml <- function(x, xpath = NULL) {
  if (!is.null(xpath)) {
    x <- xml2::xml_find_all(x, xpath)
  }
  structure(x, class = c("pkgdown_xml", class(x)))
}
xpath_contents <- function(x, xpath) {
  x <- xml2::xml_find_all(x, xpath)

  contents <- xml2::xml_contents(x)
  if (length(contents) == 0) {
    NULL
  } else {
    xml2str(contents)
  }
}
xml2str <- function(x) {
  strings <- as.character(x, options = c("format", "no_declaration"))
  paste0(strings, collapse = "")
}

xpath_attr <- function(x, xpath, attr) {
  gsub("\r", "", xml2::xml_attr(xml2::xml_find_all(x, xpath), attr), fixed = TRUE)
}
xpath_text <- function(x, xpath, trim = FALSE) {
  xml2::xml_text(xml2::xml_find_all(x, xpath), trim = trim)
}
xpath_length <- function(x, xpath) {
  length(xml2::xml_find_all(x, xpath))
}
#' @export
print.pkgdown_xml <- function(x, ...) {
  cat(as.character(x, options = c("format", "no_declaration")), sep = "\n")
  invisible(x)
}
