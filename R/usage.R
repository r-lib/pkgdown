topic_usage <- function(rd) {
  usage <- rd %>%
    purrr::detect(inherits, "tag_usage") %>%
    flatten_text() %>%
    trimws()

  parse_usage(usage)
}

parse_usage <- function(usage) {
  # Un-escape infix functions
  usage <- gsub("\\\\%", "%", usage)

  # Un-html escape <-
  usage <- gsub("&lt;-", "<-", usage)

  # Not currently used because as_html strips and converts to comments

  # # Translate method, S3method, and S4method to function calls
  # usage <- gsub(
  #   "\\\\(S3)?method\\{(.*?)\\}\\{(.*?)\\}\\((.*?)\\)",
  #   "S3method(`\\1`, `\\2`, \\3)",
  #   usage
  # )
  # usage <- gsub(
  #   "\\\\S4method\\{(.*?)\\}\\{(.*?)\\}\\((.*?)\\)",
  #   "S4method(`\\1`, `\\2`, \\3)",
  #   usage
  # )

  tryCatch({
    as.list(parse(text = usage))
  }, error = function(e) {
    list()
  })
}

usage_funs <- function(usage) {
  funs <- purrr::map_chr(usage, fun_name)
  unique(funs[!is.na(funs)])
}

fun_name <- function(expr) {
  if (!is.call(expr) || length(expr) < 1) {
    return(NA_character_)
  }

  fun <- as.character(expr[[1]])

  switch(fun,
    "<-" = paste0(fun_name(expr[[2]]), "<-"),
    "S3method" = ,
    "S4method" = NA_character_,
    fun
  )
}
