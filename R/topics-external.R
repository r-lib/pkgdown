ext_topics <- function(match_strings) {
  pieces <- strsplit(match_strings, "::", fixed = TRUE)
  pkg <- purrr::map_chr(pieces, 1)
  fun <- sub("\\(\\)$", "", purrr::map_chr(pieces, 2))

  unwrap_purrr_error(
    ext_rd <- purrr::map2(pkg, fun, get_rd_from_help)
  )
  ext_title <- purrr::map_chr(ext_rd, extract_title)
  ext_href <- purrr::map2_chr(fun, pkg, downlit::href_topic)
  ext_funs <- purrr::map(ext_rd, topic_funs)

  tibble::tibble(
    name = match_strings,
    file_in = NA_character_,
    file_out = ext_href,
    alias = list(character()), # used to find icons,
    funs = ext_funs, # used list alternative names
    title = sprintf("%s (from %s)", ext_title, pkg),
    rd = list(character()),
    source = NA_character_,
    keywords = list(character()), # used for has_keyword()
    concepts = list(character()), # used for has_concept()
    internal = FALSE,
    lifecycle = list(NULL) # used for has_lifecycle
  )
}

# Fetches the parsed Rd for an external package's topic
get_rd_from_help <- function(package, alias) {
  call <- quote(build_reference_index())
  check_installed(package, "as it's used in the reference index.", call = call)

  rd <- tryCatch(
    rdtools::topic_rd(alias, package),
    error = function(e) {
      fun <- paste0(package, "::", alias)
      cli::cli_abort(
        "Could not find documentation for {.fn {fun}}.",
        call = call
      )
    }
  )

  set_classes(rd)
}
