topic_funs <- function(rd) {
  funs <- parse_usage(rd)

  # Remove all methods for functions documented in this file
  name <- purrr::map_chr(funs, "name")
  type <- purrr::map_chr(funs, "type")

  gens <- name[type == "fun"]
  self_meth <- (name %in% gens) & (type %in% c("s3", "s4"))

  purrr::map_chr(funs[!self_meth], ~ short_name(.$name, .$type, .$signature))
}

parse_usage <- function(x) {
  if (!inherits(x, "tag")) {
    usage <- paste0("\\usage{", x, "}")
    x <- rd_text(usage, fragment = FALSE)
  }

  r <- usage_code(x)
  if (length(r) == 0) {
    return(list())
  }

  exprs <- tryCatch(
    {
      parse_exprs(r)
    },
    error = function(e) {
      warning("Failed to parse usage:\n", r, call. = FALSE, immediate. = TRUE)
      list()
    }
  )

  purrr::map(exprs, usage_type)
}

short_name <- function(name, type, signature) {
  name <- escape_html(name)

  if (!is_syntactic(name)) {
    qname <- paste0("`", name, "`")
  } else {
    qname <- name
  }

  if (type == "data") {
    qname
  } else if (type == "fun") {
    if (is_infix(name)) {
      qname
    } else {
      paste0(qname, "()")
    }
  } else {
    sig <- paste0("<i>&lt;", escape_html(signature), "&gt;</i>", collapse = ",")
    paste0(qname, "(", sig, ")")
  }
}

# Given single expression generated from usage_code, extract

usage_type <- function(x) {
  if (is_symbol(x)) {
    list(type = "data", name = as.character(x))
  } else if (is_call(x, "data")) {
    list(type = "data", name = as.character(x[[2]]))
  } else if (is.call(x)) {
    if (identical(x[[1]], quote(`<-`))) {
      replacement <- TRUE
      x <- x[[2]]
    } else {
      replacement <- FALSE
    }

    out <- fun_info(x)
    out$replacement <- replacement
    out$infix <- is_infix(out$name)
    if (replacement) {
      out$name <- paste0(out$name, "<-")
    }

    out
  } else {
    stop("Unknown type: ", typeof(x), " (in ", as.character(x), ")",  call. = FALSE)
  }
}

is_infix <- function(x) {
  if (is.null(x)) {
    return(FALSE)
  }

  x <- as.character(x)
  ops <- c(
    "+", "-", "*", "^", "/",
    "==", ">", "<", "!=", "<=", ">=",
    "&", "|",
    "[[", "[", "$"
  )

  grepl("^%.*%$", x) || x %in% ops
}

fun_info <- function(fun) {
  stopifnot(is.call(fun))

  if (is.call(fun[[1]])) {
    x <- fun[[1]]
    if (identical(x[[1]], quote(S3method))) {
      list(
        type = "s3",
        name = as.character(x[[2]]),
        signature = as.character(x[[3]])
      )
    } else if (identical(x[[1]], quote(S4method))) {
      list(
        type = "s4",
        name = as.character(x[[2]]),
        signature = as.character(x[[3]][-1])
      )
    } else if (is_call(x, c("::", ":::"))) {
      # TRUE if fun has a namespace, pkg::fun()
      list(
        type = "fun",
        name = call_name(fun)
      )
    } else {
      stop("Unknown call: ", as.character(x[[1]]))
    }
  } else {
    list(
      type = "fun",
      name = as.character(fun[[1]]),
      signature = NULL
    )
  }
}

# usage_code --------------------------------------------------------------
# Transform Rd embedded inside usage into parseable R code

usage_code <- function(x) {
  UseMethod("usage_code")
}

#' @export
usage_code.Rd <- function(x) {
  usage <- purrr::detect(x, inherits, "tag_usage")
  usage_code(usage)
}

#' @export
usage_code.NULL <- function(x) character()

# Tag without additional class use
#' @export
usage_code.tag <- function(x) {
  if (!identical(class(x), "tag")) {
    stop("Undefined tag in usage ", class(x)[[1]], call. = FALSE)
  }
  paste0(purrr::flatten_chr(purrr::map(x, usage_code)), collapse = "")
}

#' @export
usage_code.tag_dots <- function(x) "..."
#' @export
usage_code.tag_ldots <- function(x) "..."

#' @export
usage_code.TEXT <-    function(x) as.character(x)
#' @export
usage_code.RCODE <-   function(x) as.character(x)
#' @export
usage_code.VERB <-    function(x) as.character(x)
#' @export
usage_code.COMMENT <- function(x) character()

#' @export
usage_code.tag_S3method <- function(x) {
  generic <- paste0(usage_code(x[[1]]), collapse = "")
  class <- paste0(usage_code(x[[2]]), collapse = "")

  paste0("S3method(`", generic, "`, ", class, ")")
}

#' @export
usage_code.tag_method <- usage_code.tag_S3method

#' @export
usage_code.tag_S4method <- function(x) {
  generic <- paste0(usage_code(x[[1]]), collapse = "")
  class <- paste0(usage_code(x[[2]]), collapse = "")

  paste0("S4method(`", generic, "`, list(", class, "))")
}
#' @export
usage_code.tag_usage <- function(x) {
  paste0(purrr::flatten_chr(purrr::map(x, usage_code)), collapse = "")
}
