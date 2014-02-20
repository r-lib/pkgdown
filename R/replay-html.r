escape_html <- function(x) {
  x <- str_replace_all(x, "&", "&amp;")
  x <- str_replace_all(x, "<", "&lt;")
  x <- str_replace_all(x, ">", "&gt;")
  x <- str_replace_all(x, "'", "&#39;")
  x <- str_replace_all(x, "\"", "&quot;")
  x
}

# Replay a list of evaluated results, just like you'd run them in a R
# terminal, but rendered as html

replay_html <- function(x, ...) UseMethod("replay_html", x)

#' @importFrom evaluate is.source
#' @export
replay_html.list <- function(x, ...) {
  # Stitch adjacent source blocks back together
  src <- vapply(x, is.source, logical(1))
  # New group whenever not source, or when src after not-src
  group <- cumsum(!src | c(FALSE, src[-1] != src[-length(src)]))

  parts <- split(x, group)
  parts <- lapply(parts, function(x) {
    if (length(x) == 1) return(x[[1]])
    src <- str_c(vapply(x, "[[", "src", FUN.VALUE = character(1)),
      collapse = "")
    structure(list(src = src), class = "source")
  })

  pieces <- character(length(parts))
  for (i in seq_along(parts)) {
    pieces[i] <- replay_html(parts[[i]], obj_id = i, ...)
  }
  str_c(pieces, collapse = "\n")
}

#' @export
replay_html.NULL <- function(x, ...) ""

#' @export
replay_html.character <- function(x, ...) {
  str_c("<div class='output'>", str_c(escape_html(x), collapse = ""), "</div>")
}

#' @export
replay_html.value <- function(x, ...) {
  if (!x$visible) return()

  printed <- str_c(capture.output(print(x$value)), collapse = "\n")
  str_c("<div class='output'>", escape_html(printed), "</div>")
}

#' @export
replay_html.source <- function(x, ..., pkg) {
  str_c("<div class='input'>", src_highlight(escape_html(x$src), pkg$rd_index),
    "</div>")
}

#' @export
replay_html.warning <- function(x, ...) {
  str_c("<strong class='warning'>Warning message:\n", escape_html(x$message), "</strong>")
}

#' @export
replay_html.message <- function(x, ...) {
  str_c("<strong class='message'>", escape_html(str_replace(x$message, "\n$", "")),
   "</strong>")
}

#' @export
replay_html.error <- function(x, ...) {
  if (is.null(x$call)) {
    str_c("<strong class='error'>Error: ", escape_html(x$message), "</strong>")
  } else {
    call <- deparse(x$call)
    str_c("<strong class='error'>Error in ", escape_html(call), ": ",
      escape_html(x$message), "</strong>")
  }
}

#' @export
replay_html.recordedplot <- function(x, pkg, name_prefix, obj_id, ...) {
  name <- str_c(name_prefix, obj_id, ".png")
  path <- file.path(pkg$site_path, name)

  if (!file.exists(path)) {
    png(path, width = 400, height = 400, res = 96)
    on.exit(dev.off())
    print(x)
  }

  str_c("<p><img src='", escape_html(name), "' alt='' width='400' height='400' /></p>")
}
