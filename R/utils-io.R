# Reading -----------------------------------------------------------------

read_file <- function(path) {
  lines <- readLines(path, warn = FALSE)
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
