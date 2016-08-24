escape_html <- function(x) {
  x <- str_replace_all(x, "&", "&amp;")
  x <- str_replace_all(x, "<", "&lt;")
  x <- str_replace_all(x, ">", "&gt;")
  x <- str_replace_all(x, "'", "&#39;")
  x <- str_replace_all(x, "\"", "&quot;")
  x
}

message_html <- function(x) {
  x <- escape_html(x)
  paste0(x, collapse = "<br />\n")
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

  # keep only high level plots
  parts <- merge_low_plot(parts)

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

  printed <- str_c(utils::capture.output(print(x$value)), collapse = "\n")
  str_c("<div class='output'>", escape_html(printed), "</div>")
}

#' @export
replay_html.source <- function(x, ..., pkg) {
  html <- src_highlight(x$src, pkg$rd_index)
  if (identical(x$src, html)) {
    html <- escape_html(x$src)
  }
  str_c("<div class='input'>", html, "</div>")
}

#' @export
replay_html.warning <- function(x, ...) {
  str_c("<strong class='warning'>Warning message:\n", message_html(x$message), "</strong>")
}

#' @export
replay_html.message <- function(x, ...) {
  str_c("<strong class='message'>", message_html(str_replace(x$message, "\n$", "")),
   "</strong>")
}

#' @export
replay_html.error <- function(x, ...) {
  if (is.null(x$call)) {
    str_c("<strong class='error'>Error: ", message_html(x$message), "</strong>")
  } else {
    call <- paste0(deparse(x$call), collapse = "")
    str_c("<strong class='error'>Error in ", escape_html(call), ": ",
      message_html(x$message), "</strong>")
  }
}

#' @export
replay_html.recordedplot <- function(x, pkg, name_prefix, obj_id, ...) {
  name <- str_c(name_prefix, obj_id, ".png")
  path <- file.path(pkg$site_path, name)

  if (!file.exists(path)) {
    grDevices::png(path, width = 540, height = 400)
    on.exit(grDevices::dev.off())
    print(x)
  }
  str_c("<p><img src='", escape_html(name), "' alt='' width='540' height='400' /></p>")
}

# Knitr functions ------------------------------------------------------------
# The functions below come from package knitr (Yihui Xie) in file plot.R

# get MD5 digests of recorded plots so that merge_low_plot works
digest_plot = function(x, level = 1) {
  if (!is.list(x) || level >= 3) return(digest::digest(x))
  lapply(x, digest_plot, level = level + 1)
}

# merge low-level plotting changes
merge_low_plot = function(x, idx = sapply(x, evaluate::is.recordedplot)) {
  idx = which(idx); n = length(idx); m = NULL # store indices that will be removed
  if (n <= 1) return(x)

  # digest of recorded plots
  rp_dg <- lapply(x[idx], digest_plot)

  i1 = idx[1]; i2 = idx[2]  # compare plots sequentially
  for (i in 1:(n - 1)) {
    # remove the previous plot and move its index to the next plot
    if (is_low_change(rp_dg[[i]], rp_dg[[i+1]])) m = c(m, i1)
    i1 = idx[i + 1]
    i2 = idx[i + 2]
  }
  if (is.null(m)) x else x[-m]
}

# compare two recorded plots
is_low_change = function(p1, p2) {
  p1 = p1[[1]]; p2 = p2[[1]]  # real plot info is in [[1]]
  if ((n2 <- length(p2)) < (n1 <- length(p1))) return(FALSE)  # length must increase
  identical(p1[1:n1], p2[1:n1])
}
