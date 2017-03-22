# @return An integer vector giving selected topics
select_topics <- function(match_strings, topics) {
  n <- nrow(topics)
  if (length(match_strings) == 0) {
    return(integer())
  }

  expr <- purrr::map(match_strings, match_expr)
  env <- match_env(topics)
  indexes <- purrr::map(expr, eval, env = env)

  # Combine integer positions; adding if +ve, removing if -ve
  sel <- switch(
    all_sign(indexes[[1]], match_strings[[0]]),
    "+" = integer(),
    "-" = seq_len(n)[!topics$internal]
  )
  for (i in seq_along(indexes)) {
    index <- indexes[[i]]

    sel <- switch(all_sign(index, match_strings[[i]]),
      "+" = union(sel, index),
      "-" = setdiff(sel, -index)
    )
  }

  sel
}

all_sign <- function(x, text) {
  if (is.numeric(x)) {
    if (all(x < 0)) {
      return("-")
    }

    if (all(x > 0)) {
      return("+")
    }
  }

  stop("Must be all negative or all positive: ", text, call. = FALSE)
}

match_env <- function(topics) {
  any_alias <- function(f, ..., .internal = FALSE) {
    alias_match <- topics$alias %>%
      unname() %>%
      purrr::map(f, ...) %>%
      purrr::map_lgl(any)

    name_match <- topics$name %>%
      purrr::map_lgl(f, ...)

    which((alias_match | name_match) & is_public(.internal))
  }

  is_public <- function(internal) {
    if (!internal) !topics$internal else rep(TRUE, nrow(topics))
  }

  # dplyr-like matching functions
  funs <- list(
    starts_with = function(x, internal = FALSE) {
      any_alias(~ grepl(paste0("^", x), .), .internal = internal)
    },
    ends_with = function(x, internal = FALSE) {
      any_alias(~ grepl(paste0(x, "$"), .), .internal = internal)
    },
    matches = function(x, internal = FALSE) {
      any_alias(~ grepl(x, .), .internal = internal)
    },
    contains = function(x, internal = FALSE) {
      any_alias(~ grepl(x, ., fixed = TRUE), .internal = internal)
    },
    has_concept = function(x, internal = FALSE) {
      match <- topics$concepts %>%
        unname() %>%
        purrr::map(~ trimws(.) == x) %>%
        purrr::map_lgl(any)

      which(match & is_public(internal))
    }
  )

  # Each alias is mapped to the position of its topic
  lengths <- purrr::map_int(topics$alias, length)
  aliases <- seq_along(topics$alias) %>%
    rep(lengths) %>%
    as.list() %>%
    stats::setNames(purrr::flatten_chr(topics$alias))

  # Each name is mapped to the position of its topic
  names <- seq_along(topics$name) %>%
    as.list() %>%
    stats::setNames(topics$name)

  c(funs, aliases, names)
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

