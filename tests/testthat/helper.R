local_citation_activate <- function(path, envir = caller_env()) {
  old <- path(path, "inst", "temp-citation")
  new <- path(path, "inst", "CITATION")

  file_move(old, new)
  withr::defer(file_move(new, old), envir = envir)
}
