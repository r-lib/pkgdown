set_contains <- function(haystack, needles) {
  all(needles %in% haystack)
}
split_at_linebreaks <- function(text) {
  if (length(text) < 1)
    return(character())
  str_trim(strsplit(text, "\\n\\s*\\n")[[1]])
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

## For functions, we can just take their environment.

find_reexport_source <- function(obj, ns, topic) {
  if (is.function(obj)) {
    ns_env_name(get_env(obj))
  } else {
    find_reexport_source_from_imports(ns, topic)
  }
}

## For other objects, we need to check the import env of the package,
## to see where 'topic' is coming from. The import env has redundant
## information. It seems that we just need to find a named list
## entry that contains `topic`. We take the last match, in case imports
## have name clashes.

find_reexport_source_from_imports  <- function(ns, topic)  {
  imp <- getNamespaceImports(ns)
  imp <- imp[names(imp) != ""]
  wpkgs <- purrr::map_lgl(imp, `%in%`, x = topic)
  if (!any(wpkgs)) stop("Cannot find reexport source for `", topic, "`")
  pkgs <- names(wpkgs)[wpkgs]
  pkgs[[length(pkgs)]]
}

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
