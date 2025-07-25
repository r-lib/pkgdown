# Reading -----------------------------------------------------------------

read_file <- function(path) {
  lines <- read_lines(path)
  paste0(lines, "\n", collapse = "")
}


# Inspired by roxygen2 utils-io.R (https://github.com/klutometis/roxygen/) --------
read_lines <- function(path, n = -1L) {
  base::readLines(path, n = n, encoding = "UTF-8", warn = FALSE) # nolint
}

write_lines <- function(text, path) {
  base::writeLines(enc2utf8(text), path, useBytes = TRUE) # nolint
}

# Other -------------------------------------------------------------------

file_equal <- function(src, dst) {
  if (!file_exists(dst)) {
    return(FALSE)
  }

  src_hash <- rlang::hash_file(src)
  dst_hash <- rlang::hash_file(dst)

  identical(src_hash, dst_hash)
}
