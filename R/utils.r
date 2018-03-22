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
