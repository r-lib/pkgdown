highlight_text <- function(text) {
  out <- downlit::highlight(text, classes = downlit::classes_pandoc())
  if (is.na(out)) {
    escape_html(text)
  } else {
    out
  }
}

set_contains <- function(haystack, needles) {
  all(needles %in% haystack)
}

split_at_linebreaks <- function(text) {
  if (length(text) < 1)
    return(character())
  strsplit(text, "\\n\\s*\\n")[[1]]
}

up_path <- function(depth) {
  paste(rep.int("../", depth), collapse = "")
}

dir_depth <- function(x) {
  x %>%
    strsplit("") %>%
    purrr::map_int(function(x) sum(x == "/"))
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
  if (rstudioapi::hasFun("documentSaveAll")) {
    rstudioapi::documentSaveAll()
  }
}

is_syntactic <- function(x) x == make.names(x)

str_trim <- function(x) gsub("^\\s+|\\s+$", "", x)

# devtools metadata -------------------------------------------------------

devtools_loaded <- function(x) {
  if (!x %in% loadedNamespaces()) {
    return(FALSE)
  }
  ns <- .getNamespace(x)
  env_has(ns, ".__DEVTOOLS__")
}

devtools_meta <- function(x) {
  ns <- .getNamespace(x)
  ns[[".__DEVTOOLS__"]]
}

# CLI ---------------------------------------------------------------------

dst_path <- function(...) {
  crayon::blue(encodeString(path(...), quote = "'"))
}

src_path <- function(...) {
  crayon::green(encodeString(path(...), quote = "'"))
}

cat_line <- function(...) {
  cat(paste0(..., "\n"), sep = "")
}

rule <- function(left, ...) {
  cli::cat_rule(left = crayon::bold(left), ...)
}

yaml_list <- function(...) print_yaml(list(...))

print_yaml <- function(x) {
  structure(x, class = "print_yaml")
}

#' @export
print.print_yaml <- function(x, ...) {
  cat(yaml::as.yaml(x), "\n", sep = "")
}

skip_if_no_pandoc <- function() {
  testthat::skip_if_not(rmarkdown::pandoc_available("1.12.3"))
}

has_internet <- function() {
  return(getOption("pkgdown.internet", default = TRUE))
}

with_dir <- function(new, code) {
  old <- setwd(dir = new)
  on.exit(setwd(old))
  force(code)
}

# remove '' quoting
# e.g. 'title' becomes title.s
cran_unquote <- function(string) {
  gsub("\\'(.*?)\\'", "\\1", string)
}
