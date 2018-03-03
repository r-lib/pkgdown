# Reading -----------------------------------------------------------------

read_file <- function(path) {
  lines <- read_lines(path)
  paste0(lines, "\n", collapse = "")
}

# Writing -----------------------------------------------------------------

write_yaml <- function(x, path) {
  write_lines(yaml::as.yaml(x), path = path)
}

# Inspired by roxygen2 utils-io.R (https://github.com/klutometis/roxygen/) -----------

readLines <- function(...) stop("Use read_lines!")
writeLines <- function(...) stop("Use write_lines!")

read_lines <- function(path, n = -1L) {
  base::readLines(path, n = n, encoding = "UTF-8", warn = FALSE)
}

write_lines <- function(text, path) {
  base::writeLines(enc2utf8(text), path, useBytes = TRUE)
}
