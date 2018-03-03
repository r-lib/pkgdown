# Reading -----------------------------------------------------------------

read_file <- function(path) {
  lines <- read_lines(path)
  paste0(lines, "\n", collapse = "")
}

# Writing -----------------------------------------------------------------

write_utf8 <- function(..., path, sep = "") {
  file <- file(path, open = "w", encoding = "UTF-8")
  on.exit(close(file))
  cat(..., file = file, sep = sep)
}

write_yaml <- function(x, path) {
  write_utf8(yaml::as.yaml(x), "\n", path = path, sep = "")
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
