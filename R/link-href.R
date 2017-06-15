# Compared to the others this returns NA if no link is found
# Should probably refactor others to be consistent
href_string <- function(x, bare_symbol = FALSE) {
  expr <- tryCatch(parse(text = x)[[1]], error = function(e) NULL)
  if (is.null(expr)) {
    return(NA_character_)
  }

  href <- href_expr(expr, bare_symbol = bare_symbol)
  if (is.null(href)) {
    return(NA_character_)
  }
  href
}


href_expr <- function(expr, bare_symbol = FALSE) {
  if (is_symbol(expr) && bare_symbol) {
    # foo
    href_topic_local(as.character(expr))
  } else if (is_lang(expr)) {
    fun <- expr[[1]]

    if (is_lang(fun, "::", n = 2)) {
      pkg <- as.character(fun[[2]])
      fun <- fun[[3]]
    } else {
      pkg <- NULL
    }

    if (!is_symbol(fun))
      return(NULL)

    fun_name <- as.character(fun)
    if (grepl("^%.*%$", fun_name))
      return(NULL)

    n_args <- length(expr) - 1

    if (fun_name == "vignette") {
      switch(n_args,
        href_article_local(as.character(expr[[2]])),
        NULL
      )
    } else if (fun_name == "?") {
      switch(n_args,
        href_topic_local(as.character(expr[[2]])),                        # ?x,
        href_topic_local(paste0(expr[[3]], "-", expr[[2]])) # package?x
      )
    } else if (fun_name == "::") {
      href_topic_remote(as.character(expr[[3]]), as.character(expr[[2]]))
    } else {
      if (is.null(pkg)) {
        href_topic_local(fun_name)
      } else {
        href_topic_remote(fun_name, pkg)
      }
    }
  } else {
    NULL
  }
}

# Helper for testing
href_expr_ <- function(expr, ...) {
  href_expr(substitute(expr), ...)
}

href_topic_local <- function(topic) {
  rdname <- find_rdname(NULL, topic)
  if (is.null(rdname)) {
    return(NULL)
  }

  if (rdname == context_get("rdname")) {
    return(NULL)
  }

  if (context_get("rdname") != "") {
    paste0(rdname, ".html")
  } else {
    paste0(up_path(context_get("depth")), "reference/", rdname, ".html")
  }
}

href_topic_remote <- function(topic, package) {
  rdname <- find_rdname(package, topic)
  if (is.null(rdname)) {
    return(NULL)
  }

  reference_url <- remote_package_url(package)

  if (!is.null(reference_url)) {
    paste0(reference_url, paste0("/", rdname, ".html"))
  } else {
    # Fall back to rdocumentation.org which almost certainly works
    paste0("http://www.rdocumentation.org/packages/", package, "/topics/", rdname)
  }
}

href_article_local <- function(article) {
  paste0(up_path(context_get("depth")), "articles/", article, ".html")
}
