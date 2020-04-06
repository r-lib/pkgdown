# @return An integer vector giving selected topics
select_topics <- function(match_strings, topics, check = FALSE) {
  n <- nrow(topics)
  if (length(match_strings) == 0) {
    return(integer())
  }

  indexes <- purrr::map(match_strings, match_eval, env = match_env(topics))

  # If none of the specified topics have a match, return no topics
  if (purrr::every(indexes, is_empty)) {
    if (check) {
      warn("No topics matched in '_pkgdown.yml'. No topics selected.")
    }
    return(integer())
  }

  # Combine integer positions; adding if +ve, removing if -ve
  sel <- switch(
    all_sign(indexes[[1]], match_strings[[1]]),
    "+" = integer(),
    "-" = seq_len(n)[!topics$internal]
  )

  for (i in seq2(1, length(indexes))) {
    index <- indexes[[i]]

    if (check && length(index) == 0) {
      topic_must("match a function or concept", match_strings[[i]])
    }

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
  out <- env(empty_env(),
    "-" = function(x) -x,
    "c" = function(...) c(...)
  )

  topic_index <- seq_along(topics$name)

  # Each name is mapped to the position of its topic
  env_bind(out, !!!set_names(topic_index, topics$name))

  # As is each alias
  topics$alias <- lapply(topics$alias, unique)
  aliases <- set_names(
    rep(topic_index, lengths(topics$alias)),
    unlist(topics$alias)
  )
  env_bind(out, !!!aliases)

  # dplyr-like matching functions

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
  out$starts_with <- function(x, internal = FALSE) {
    any_alias(~ grepl(paste0("^", x), .), .internal = internal)
  }
  out$ends_with <- function(x, internal = FALSE) {
    any_alias(~ grepl(paste0(x, "$"), .), .internal = internal)
  }
  out$matches <- function(x, internal = FALSE) {
    any_alias(~ grepl(x, .), .internal = internal)
  }
  out$contains <- function(x, internal = FALSE) {
    any_alias(~ grepl(x, ., fixed = TRUE), .internal = internal)
  }
  out$has_keyword <- function(x) {
    which(purrr::map_lgl(topics$keywords, ~ any(. %in% x)))
  }
  out$has_concept <- function(x, internal = FALSE) {
    match <- topics$concepts %>%
      purrr::map(~ str_trim(.) == x) %>%
      purrr::map_lgl(any)

    which(match & is_public(internal))
  }
  out$lacks_concepts <- function(x, internal = FALSE) {
    nomatch <- topics$concepts %>%
      purrr::map(~ match(str_trim(.), x, nomatch = FALSE)) %>%
      purrr::map_lgl(~ length(.) == 0L | all(. == 0L))

    which(nomatch & is_public(internal))
  }

  out
}


match_eval <- function(string, env) {
  # Early return in case string already matches symbol
  if (env_has(env, string)) {
    val <- env[[string]]
    if (is.integer(val)) {
      return(val)
    }
  }

  expr <- tryCatch(parse_expr(string), error = function(e) NULL)
  if (is.null(expr)) {
    topic_must("be valid R code", string)
    return(integer())
  }

  if (is_string(expr) || is_symbol(expr)) {
    expr <- as.character(expr)
    val <- env_get(env, expr, default = NULL)
    if (is.integer(val)) {
      val
    } else {
      topic_must("be a known topic name or alias", string)
      integer()
    }
  } else if (is_call(expr)) {
    value <- tryCatch(eval(expr, env), error = function(e) NULL)

    if (is.null(value)) {
      topic_must("be a known selector function", string)
      integer()
    } else {
      value
    }
  } else {
    topic_must("be a string or function call", string)
    integer()
  }
}

topic_must <- function(message, topic) {
  warn(c(
    paste0("In '_pkgdown.yml', topic must ", message),
    x = paste0("Not ", encodeString(topic, quote = "'"))
  ))
}
