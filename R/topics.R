# @param topics A list of character vectors giving the aliases in each Rf file
# @param matches A list of strings describing matching functions
# @return logical vector same length as `topics`
has_topic <- function(match_strings, topics) {
  n <- nrow(topics)
  if (length(match_strings) == 0) {
    return(rep(FALSE, n))
  }

  expr <- purrr::map(match_strings, match_expr)
  env <- match_env(topics)
  indexes <- purrr::map(expr, eval, env = env)

  # Combine integer positions; adding if +ve, removing if -ve
  sel <- switch(all_sign(indexes[[1]]), "+" = integer(), "-" = seq_len(n))
  for (index in indexes) {
    sel <- switch(all_sign(index),
      "+" = union(sel, index),
      "-" = setdiff(sel, -index)
    )
  }

  seq_len(n) %in% sel
}

all_sign <- function(x) {
  if (is.numeric(x)) {
    if (all(x < 0)) {
      return("-")
    }

    if (all(x > 0)) {
      return("+")
    }
  }

  stop("Must be all negative or all positive", call. = FALSE)
}

match_env <- function(topics) {
  any_alias <- function(f, ...) {
    topics$alias %>%
      unname() %>%
      purrr::map(f, ...) %>%
      purrr::map_lgl(any) %>%
      which()
  }

  # dplyr-like matching functions
  funs <- list(
    starts_with = function(x) {
      any_alias(~ grepl(paste0("^", x), .))
    },
    ends_with = function(x) {
      any_alias(~ grepl(paste0(x, "$"), .))
    },
    matches = function(x) {
      any_alias(~ grepl(x, .))
    },
    contains = function(x) {
      any_alias(~ grepl(x, ., fixed = TRUE))
    }
  )

  # Each alias is mapped to the position of its topic
  lengths <- purrr::map_int(topics$alias, length)
  aliases <- seq_along(topics$alias) %>%
    rep(lengths) %>%
    as.list() %>%
    stats::setNames(purrr::flatten_chr(topics$alias))

  c(funs, aliases)
}

# Takes text specification and converts it to a predicate function
match_expr <- function(match_string) {
  stopifnot(is.character(match_string), length(match_string) == 1)
  text_quoted <- encodeString(match_string, quote = "`")

  tryCatch({
    expr <- parse(text = match_string)[[1]]
  }, error = function(e) {
    stop(
      "Failed to parse: ", text_quoted, " in `_pkgdown.yml`\n",
      e$message,
      call. = FALSE
    )
  })

  if (is.call(expr) || is.name(expr) || is.character(expr)) {
    expr
  } else {
    stop("Unknown expression: ", text_quoted, " in `_pkgdown.yml`\n", call. = FALSE)
  }
}

