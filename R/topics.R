# @return An integer vector giving selected topics
select_topics <- function(
  match_strings,
  topics,
  check = FALSE,
  error_path,
  error_pkg,
  error_call = caller_env()
) {
  n <- nrow(topics)
  if (length(match_strings) == 0) {
    return(integer())
  }

  indexes <- unwrap_purrr_error(purrr::imap(
    match_strings,
    match_eval,
    env = match_env(topics),
    error_path = error_path,
    error_pkg = error_pkg,
    error_call = error_call
  ))

  # If none of the specified topics have a match, return no topics
  if (purrr::every(indexes, is_empty)) {
    if (check) {
      msg <- "{.field {error_path}} failed to match any topics."
      config_abort(error_pkg, msg, call = error_call)
    }
    return(integer())
  }

  no_match <- match_strings[purrr::map_lgl(indexes, rlang::is_empty)]
  if (check && length(no_match) > 0) {
    topic_must(
      "match a function or concept",
      toString(no_match),
      error_pkg = error_pkg,
      error_path = error_path,
      error_call = error_call
    )
  }

  indexes <- purrr::discard(indexes, is_empty)
  # Combine integer positions; adding if +ve, removing if -ve
  sign <- all_sign(
    indexes[[1]],
    match_strings[[1]],
    error_pkg = error_pkg,
    error_path = paste0(error_path, "[1]"),
    error_call = error_call
  )
  sel <- switch(sign, "+" = integer(), "-" = seq_len(n)[!topics$internal])

  for (i in seq2(1, length(indexes))) {
    index <- indexes[[i]]

    sign <- all_sign(
      indexes[[i]],
      match_strings[[i]],
      error_pkg = error_pkg,
      error_path = paste0(error_path, "[", i, "]"),
      error_call = error_call
    )
    sel <- switch(
      sign,
      "+" = union(sel, indexes[[i]]),
      "-" = setdiff(sel, -indexes[[i]])
    )
  }
  sel
}

all_sign <- function(
  x,
  text,
  error_pkg,
  error_path,
  error_call = caller_env()
) {
  if (is.numeric(x)) {
    if (all(x < 0)) {
      return("-")
    }

    if (all(x > 0)) {
      return("+")
    }
  }
  config_abort(
    error_pkg,
    "{.field {error_path}} ({text}) must be all negative or all positive.",
    call = error_call
  )
}

match_env <- function(topics) {
  fns <- env(empty_env(), "-" = function(x) -x, "c" = function(...) c(...))
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
    f <- as_function(f)
    alias_match <- purrr::map_lgl(unname(topics$alias), function(x) {
      any(f(x, ...))
    })
    name_match <- purrr::map_lgl(topics$name, f, ...)

    which((alias_match | name_match) & is_public(.internal))
  }

  is_public <- function(internal) {
    if (!internal) !topics$internal else rep(TRUE, nrow(topics))
  }
  fns$starts_with <- function(x, internal = FALSE) {
    check_string(x)
    check_bool(internal)

    any_alias(~ grepl(paste0("^", x), .), .internal = internal)
  }
  fns$ends_with <- function(x, internal = FALSE) {
    check_string(x)
    check_bool(internal)

    any_alias(~ grepl(paste0(x, "$"), .), .internal = internal)
  }
  fns$matches <- function(x, internal = FALSE) {
    check_string(x)
    check_bool(internal)

    any_alias(~ grepl(x, .), .internal = internal)
  }
  fns$contains <- function(x, internal = FALSE) {
    check_string(x)
    check_bool(internal)

    any_alias(~ grepl(x, ., fixed = TRUE), .internal = internal)
  }
  fns$has_keyword <- function(x) {
    check_character(x)
    which(purrr::map_lgl(topics$keywords, ~ any(. %in% x)))
  }
  fns$has_lifecycle <- function(x) {
    check_string(x)
    which(purrr::map_lgl(topics$lifecycle, ~ any(. %in% x)))
  }
  fns$has_concept <- function(x, internal = FALSE) {
    check_string(x)
    check_bool(internal)

    match <- purrr::map_lgl(topics$concepts, ~ any(str_trim(.) == x))
    which(match & is_public(internal))
  }
  fns$lacks_concepts <- function(x, internal = FALSE) {
    check_character(x)
    check_bool(internal)

    match <- purrr::map_lgl(topics$concepts, ~ any(str_trim(.) == x))
    which(!match & is_public(internal))
  }
  fns$lacks_concept <- fns$lacks_concepts
  out
}

match_eval <- function(
  string,
  index,
  env,
  error_pkg,
  error_path,
  error_call = caller_env()
) {
  error_path <- paste0(error_path, "[", index, "]")

  # Early return in case string already matches symbol
  if (env_has(env, string)) {
    val <- env[[string]]
    if (is.integer(val)) {
      return(val)
    }
  }

  expr <- tryCatch(parse_expr(string), error = function(e) NULL)
  if (is.null(expr)) {
    topic_must(
      "be valid R code",
      string,
      error_pkg = error_pkg,
      error_path = error_path,
      error_call = error_call
    )
  }

  if (is_string(expr) || is_symbol(expr)) {
    expr <- as.character(expr)
    val <- env_get(env, expr, default = NULL)
    if (is.integer(val)) {
      val
    } else {
      topic_must(
        "be a known topic name or alias",
        string,
        error_pkg = error_pkg,
        error_path = error_path,
        error_call = error_call
      )
    }
  } else if (is_call(expr, "::")) {
    name <- paste0(expr[[2]], "::", expr[[3]])
    val <- env_get(env, name, default = NULL)
    if (is.integer(val)) {
      val
    } else {
      topic_must(
        "be a known topic name or alias",
        string,
        error_pkg = error_pkg,
        error_path = error_path,
        error_call = error_call
      )
    }
  } else if (is_call(expr)) {
    withCallingHandlers(
      eval(expr, env),
      error = function(e) {
        config_abort(
          error_pkg,
          "{.field {error_path}} ({string}) failed to evaluate.",
          parent = e,
          call = error_call
        )
      }
    )
  } else {
    topic_must(
      "be a string or function call",
      string,
      error_pkg = error_pkg,
      error_path = error_path,
      error_call = error_call
    )
  }
}

topic_must <- function(message, topic, error_pkg, error_path, error_call, ...) {
  msg <- "{.field {error_path}} ({topic}) must {message}."
  config_abort(error_pkg, msg, call = error_call, ...)
}

section_topics <- function(
  pkg,
  match_strings,
  error_path,
  error_call = error_call()
) {
  # Add rows for external docs
  ext_strings <- match_strings[grepl("::", match_strings, fixed = TRUE)]
  topics <- rbind(pkg$topics, ext_topics(ext_strings))

  idx <- select_topics(
    match_strings,
    topics,
    error_pkg = pkg,
    error_path = error_path,
    error_call = error_call
  )
  selected <- topics[idx, , drop = FALSE]

  tibble::tibble(
    name = selected$name,
    path = selected$file_out,
    title = selected$title,
    lifecycle = selected$lifecycle,
    aliases = purrr::map2(
      selected$funs,
      selected$alias,
      ~ if (length(.x) > 0) .x else .y
    ),
    icon = find_icons(selected$alias, path(pkg$src_path, "icons"))
  )
}
