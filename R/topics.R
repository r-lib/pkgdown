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

content_info <- function(content_entry, index, pkg, section) {

  if (!grepl("::", content_entry, fixed = TRUE)) {
    topics <- pkg$topics[select_topics(content_entry, pkg$topics),]
    tibble::tibble(
      path = topics$file_out,
      aliases = purrr::map2(topics$funs, topics$name, ~ if (length(.x) > 0) .x else .y),
      name = list(topics$name),
      title = topics$title,
      icon = find_icons(topics$alias, path(pkg$src_path, "icons"))
    )
  } else { # topic from another package
    names <- strsplit(content_entry, "::")[[1]]
    pkg_name <- names[1]
    topic <- names[2]
    check_package_presence(pkg_name)

    rd_href <- find_rd_href(sub("\\(\\)$", "", topic), pkg_name)
    rd <- get_rd(rd_href, pkg_name)
    rd_title <- extract_title(rd)
    rd_aliases <- find_rd_aliases(rd)

    tibble::tibble(
      path = rd_href,
      aliases = rd_aliases,
      name = list(content_entry = NULL),
      title = sprintf("%s (from %s)", rd_title, pkg_name),
      icon = list(content_entry = NULL)
    )
  }
}

check_package_presence <- function(pkg_name) {
  rlang::check_installed(
    pkg = pkg_name,
    reason = "as it is mentioned in the reference index."
  )
}

get_rd <- function(rd_href, pkg_name) {
  rd_name <- fs::path_ext_set(fs::path_file(rd_href), "Rd")
  # adapted from printr
  # https://github.com/yihui/printr/blob/0267c36f49e92bd99e5434f695f80b417d14e090/R/help.R#L32
  db <- tools::Rd_db(pkg_name)
  Rd <- db[[rd_name]]
  set_classes(Rd)
}

find_rd_aliases <- function(rd) {
  funs <- topic_funs(rd)
  if (length(funs) > 0) {
    list(funs)
  } else {
    extract_tag(rd, "tag_name")
  }
}

find_rd_href <- function(topic, pkg_name) {
  href <- downlit::href_topic(topic, pkg_name)
  if (is.na(href)) {
    abort(
      sprintf(
        "Could not find an href for topic %s of package %s",
        topic, pkg_name
      )
    )
  }
  href
}
