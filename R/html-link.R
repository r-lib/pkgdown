
link_remote <- function(label, topic, package) {
  # Return early if package not installed
  if (!requireNamespace(package, quietly = TRUE)) {
    return(label)
  }

  help <- eval(bquote(help(.(topic), .(package))))
  if (length(help) == 0) {
    return(label)
  }

  path <- strsplit(help, "/")[[1]]
  n <- length(path)

  sprintf(
    "<a href='http://www.rdocumentation.org/packages/%s/topics/%s'>%s</a>",
    path[n - 2],
    path[n],
    label
  )
}

find_local_topic <- function(alias, index, current = NULL) {
  if (is.null(alias))
    return()

  match <- purrr::detect_index(index$alias, function(x) any(x == alias))
  if (match == 0)
    return()

  topic <- index$name[match]
  path <- index$file_out[match]

  if (!is.null(current) && topic == current) {
    NULL
  } else {
    path
  }
}

link_local <- function(label, topic, index, current = NULL) {
  path <- find_local_topic(topic, index = index, current = current)
  if (is.null(path)) {
    label
  } else {
    paste0("<a href='", path, "'>", label, "</a>")
  }
}

# Autolink html -----------------------------------------------------------

# Modifies in place
autolink_html <- function(x, depth = 1L, index = NULL) {
  stopifnot(inherits(x, "xml_node"))

  # <code> with no children
  x %>%
    xml2::xml_find_all(".//code[count(*) = 0]") %>%
    autolink_nodeset(strict = TRUE, index = index, depth = depth)

  # <span class='kw'>
  x %>%
    xml2::xml_find_all(".//span[@class='kw']") %>%
    autolink_nodeset(strict = FALSE, index = index, depth = depth)

  invisible()
}

autolink_nodeset <- function(nodes, strict = TRUE, depth = 1L, index = NULL) {
  links <- nodes %>%
    xml2::xml_text() %>%
    purrr::map_chr(autolink_call, strict = strict, index = index, depth = depth)

  has_link <- !is.na(links)
  if (!any(has_link))
    return()

  nodes[has_link] %>%
    xml2::xml_contents() %>%
    xml2::xml_replace(purrr::map(links[has_link], xml2::read_xml))

  invisible()
}

# Need to convert expressions of the form:
# * foo()
# * foo (but only in large code blocks)
# * ?topic
# * ?"topic-with-special-chars"
# * package?docs
# * vignette("name")
autolink_call <- function(x, strict = TRUE, index = NULL, depth = 1L) {
  expr <- tryCatch(parse(text = x)[[1]], error = function(x) NULL)
  if (is.null(expr)) {
    return(NA_character_)
  }

  # Don't auto link infix operators
  if (is_call_infix(expr)) {
    return(NA_character_)
  }

  if (is_call_vignette(expr)) {
    return(link_vignette(expr, x, depth = depth))
  }

  alias <- find_alias(expr, strict = strict)
  path <- find_local_topic(alias, index = index)
  if (is.null(path)) {
    return(NA_character_)
  }

  href <- paste0(up_path(depth), "reference/", path)
  paste0("<a href='", href, "'>", x, "</a>")
}

link_vignette <- function(expr, text, depth) {
  if (length(expr) != 2) {
    return(NA_character_)
  }

  href <- paste0(up_path(depth), "articles/", as.character(expr[[2]]), ".html")
  paste0("<a href='", href, "'>", text, "</a>")
}

find_alias <- function(x, strict = TRUE) {
  if (is_call_help(x)) {
    if (length(x) == 2) {
      as.character(x[[2]])
    } else if (length(x) == 3) {
      paste0(x[[3]], "-", x[[2]])
    } else {
      NULL
    }
  } else if (!strict && is.name(x)) {
    as.character(x)
  } else if (is.call(x)) {
    fun <- x[[1]]
    if (is.name(fun)) {
      as.character(fun)
    } else {
      NULL
    }
  } else {
    NULL
  }
}

is_call_help <- function(x) {
  is.call(x) && identical(x[[1]], quote(`?`))
}

is_call_vignette <- function(x) {
  is.call(x) && identical(x[[1]], quote(vignette))
}

is_call_infix <- function(x) {
  is.call(x) && length(x == 3) && grepl("^%.*%$", as.character(x[[1]]))
}
