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
      cli::cli_abort(
        "No topics matched in {.file _pkgdown.yml}. No topics selected.",
        call = caller_env()
      )
    }
    return(integer())
  }

  no_match <- match_strings[purrr::map_lgl(indexes, rlang::is_empty)]
  if (check && length(no_match) > 0) {
    topic_must("match a function or concept", toString(no_match))
  }

  indexes <- purrr::discard(indexes, is_empty)
  # Combine integer positions; adding if +ve, removing if -ve
  sel <- switch(
    all_sign(indexes[[1]], match_strings[[1]]),
    "+" = integer(),
    "-" = seq_len(n)[!topics$internal]
  )

  for (i in seq2(1, length(indexes))) {
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

  cli::cli_abort(
    "Must be all negative or all positive: {.val {text}}",
    call = caller_env()
  )
}

match_env <- function(topics) {
  fns <- env(empty_env(),
    "-" = function(x) -x,
    "c" = function(...) c(...)
  )
  out <- env(fns)

  topic_index <- seq_along(topics$name)

  # Each \alias{} is matched to its position
  topics$alias <- lapply(topics$alias, unique)
  aliases <- set_names(
    rep(topic_index, lengths(topics$alias)),
    unlist(topics$alias)
  )
  env_bind(out, !!!aliases)

  # As is each \name{} - we bind these second so that if \name{x} and \alias{x}
  # are in different files, \name{x} wins. This doesn't usually matter, but
  # \name{} needs to win so that the default_reference_index() matches the
  # correct files
  env_bind(out, !!!set_names(topic_index, topics$name))

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
  fns$starts_with <- function(x, internal = FALSE) {
    any_alias(~ grepl(paste0("^", x), .), .internal = internal)
  }
  fns$ends_with <- function(x, internal = FALSE) {
    any_alias(~ grepl(paste0(x, "$"), .), .internal = internal)
  }
  fns$matches <- function(x, internal = FALSE) {
    any_alias(~ grepl(x, .), .internal = internal)
  }
  fns$contains <- function(x, internal = FALSE) {
    any_alias(~ grepl(x, ., fixed = TRUE), .internal = internal)
  }
  fns$has_keyword <- function(x) {
    which(purrr::map_lgl(topics$keywords, ~ any(. %in% x)))
  }
  fns$has_concept <- function(x, internal = FALSE) {
    match <- topics$concepts %>%
      purrr::map(~ str_trim(.) == x) %>%
      purrr::map_lgl(any)

    which(match & is_public(internal))
  }
  fns$lacks_concepts <- function(x, internal = FALSE) {
    nomatch <- topics$concepts %>%
      purrr::map(~ match(str_trim(.), x, nomatch = FALSE)) %>%
      purrr::map_lgl(~ length(.) == 0L | all(. == 0L))

    which(nomatch & is_public(internal))
  }
  fns$lacks_concept <- fns$lacks_concepts
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
  }

  if (is_string(expr) || is_symbol(expr)) {
    expr <- as.character(expr)
    val <- env_get(env, expr, default = NULL)
    if (is.integer(val)) {
      val
    } else {
      topic_must("be a known topic name or alias", string)
    }
  } else if (is_call(expr, "::")) {
    name <- paste0(expr[[2]], "::", expr[[3]])
    val <- env_get(env, name, default = NULL)
    if (is.integer(val)) {
      val
    } else {
      topic_must("be a known topic name or alias", string)
    }
  } else if (is_call(expr)) {
    tryCatch(
      eval(expr, env),
      error = function(e) {
        topic_must("be a known selector function", string, parent = e)
      }
    )
  } else {
    topic_must("be a string or function call", string)
  }
}

topic_must <- function(message, topic, ..., call = NULL) {
  cli::cli_abort(
    "In {.file _pkgdown.yml}, topic must {message}, not {.val {topic}}.",
    ...,
    call = call
  )
}

section_topics <- function(match_strings, topics, src_path) {
  # Add rows for external docs
  ext_strings <- match_strings[grepl("::", match_strings, fixed = TRUE)]
  topics <- rbind(topics, ext_topics(ext_strings))

  selected <- topics[select_topics(match_strings, topics), , ]

  tibble::tibble(
    name = selected$name,
    path = selected$file_out,
    title = selected$title,
    aliases = purrr::map2(selected$funs, selected$alias, ~ if (length(.x) > 0) .x else .y),
    icon = find_icons(selected$alias, path(src_path, "icons"))
  )
}
