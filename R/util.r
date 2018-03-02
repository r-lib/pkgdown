#' @importFrom magrittr %>%
#' @importFrom roxygen2 roxygenise
#' @importFrom R6 R6Class
#' @import rlang
NULL

set_contains <- function(haystack, needles) {
  all(needles %in% haystack)
}
split_at_linebreaks <- function(text) {
  if (length(text) < 1)
    return(character())
  trimws(strsplit(text, "\\n\\s*\\n")[[1]])
}

up_path <- function(depth) {
  paste(rep.int("../", depth), collapse = "")
}

print_yaml <- function(x) {
  structure(x, class = "print_yaml")
}
#' @export
print.print_yaml <- function(x, ...) {
  cat(yaml::as.yaml(x), "\n", sep = "")
}

find_first_existing <- function(path, ...) {
  paths <- file.path(path, c(...))
  for (path in paths) {
    if (file.exists(path))
      return(path)
  }

  NULL
}



read_file <- function(path) {
  lines <- readLines(path, warn = FALSE)
  paste0(lines, "\n", collapse = "")
}

write_yaml <- function(x, path) {
  write_utf8(yaml::as.yaml(x), "\n", path = path, sep = "")
}

invert_index <- function(x) {
  stopifnot(is.list(x))

  if (length(x) == 0)
    return(list())

  key <- rep(names(x), purrr::map_int(x, length))
  val <- unlist(x, use.names = FALSE)

  split(key, val)
}

a <- function(text, href) {
  ifelse(is.na(href), text, paste0("<a href='", href, "'>", text, "</a>"))
}

write_utf8 <- function(..., path, sep = "") {
  file <- file(path, open = "w", encoding = "UTF-8")
  on.exit(close(file))
  cat(..., file = file, sep = sep)
}

# Used for testing
#' @keywords internal
#' @importFrom MASS addterm
#' @export
MASS::addterm

rstudio_save_all <- function() {
  if (rstudioapi::hasFun("documentSaveAll")) {
    rstudioapi::documentSaveAll()
  }
}

cat_line <- function(...) {
  cat(..., "\n", sep = "")
}

rule <- function(...) cli::cat_rule(..., col = "green")

list_with_heading <- function(bullets, heading) {
  if (length(bullets) == 0)
    return(character())

  paste0(
    "<h2>", heading, "</h2>",
    "<ul class='list-unstyled'>\n",
    paste0("<li>", bullets, "</li>\n", collapse = ""),
    "</ul>\n"
  )
}
