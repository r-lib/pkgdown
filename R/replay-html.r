label_lines <- function(x, class = NULL, prompt = "#> ") {
  lines <- strsplit(x, "\n")[[1]]
  lines <- escape_html(lines)

  if (!is.null(class)) {
    lines <- sprintf("<span class='%s'>%s</span>", class, lines)
  }

  paste0(escape_html(prompt), lines)
}

label_output <- function(x, class = NULL, prompt = "#> ") {
  lines <- label_lines(x, class = class, prompt = prompt)
  paste0(
    "<div class='output co'>",
    paste0(lines, collapse = "\n"),
    "</div>"
  )
}

# Replay a list of evaluated results, just like you'd run them in a R
# terminal, but rendered as html

replay_html <- function(x, ...) UseMethod("replay_html", x)

#' @export
replay_html.list <- function(x, ...) {
  # Stitch adjacent source blocks back together
  src <- vapply(x, evaluate::is.source, logical(1))
  # New group whenever not source, or when src after not-src
  group <- cumsum(!src | c(FALSE, src[-1] != src[-length(src)]))

  parts <- split(x, group)
  parts <- lapply(parts, function(x) {
    if (length(x) == 1) return(x[[1]])
    src <- paste0(vapply(x, "[[", "src", FUN.VALUE = character(1)),
      collapse = "")
    structure(list(src = src), class = "source")
  })

  # keep only high level plots
  parts <- merge_low_plot(parts)

  pieces <- list()
  meta <- list()

  # replay each part, keeping output and dependencies
  for (i in seq_along(parts)) {
    output <- replay_html(parts[[i]], ...)

    pieces[[i]] <- output
    meta[[i]] <- attr(output, "knit_meta")
  }

  is_html <- function(x) {
    inherits(x, "html")
  }

  # find html pieces with meta dependencies
  html_meta <- purrr::map_lgl(
    seq_along(pieces),
    ~ is_html(pieces[[.x]]) && !is.null(meta[[.x]])
  )

  # no html with dependencies, return one big pre block
  if (!any(html_meta)) {
    out <- list(
      content = paste0(
        c("<pre class='examples'>", unlist(pieces), "</pre>"),
        collapse = ""
      )
    )
    return(out)
  }

  # identify html and break into chunks
  pre_group <- cumsum(
    !html_meta | c(FALSE, html_meta[-1] != html_meta[-length(html_meta)])
  )
  pre_parts <- split(pieces, pre_group)

  # add surrounding pre tags to non-html blocks
  out <- purrr::map_if(
    pre_parts,
    ~ !is_html(.x[[1]]),
    ~ paste0("<pre class='examples'>", unlist(.x), "</pre>")
  )

  out <- list(content = paste0(unlist(out), collapse = ""))

  meta <- collate_knit_meta(meta)
  attr(out, "html_deps") <- meta

  out
}

# Format pre blocks --------------------------------------------------

collate_knit_meta <- function(meta, lib_dir = "assets", output_dir = ".") {
  meta <- unique(purrr::flatten(meta)) %>%
    purrr::map(htmltools::copyDependencyToDir, lib_dir) %>%
    purrr::map(htmltools::makeDependencyRelative, output_dir)

  htmltools::renderDependencies(
    meta,
    "file",
    encodeFunc = identity,
    hrefFilter = function(path) {
      rmarkdown::relative_to(output_dir, path)
    }
  )
}

# replay_html ------------------------------------------------

#' @export
replay_html.NULL <- function(x, ...) ""

#' @export
replay_html.character <- function(x, ...) {
  label_output(x)
}

#' @export
replay_html.value <- function(x, ...) {
  if (!x$visible) return()

  printed <- paste0(utils::capture.output(print(x$value)), collapse = "\n")
  label_output(printed)
}

#' @export
replay_html.source <- function(x, ...) {
  html <- highlight_text(x$src)
  paste0("<div class='input'>", html, "</div>")
}

#' @export
replay_html.warning <- function(x, ...) {
  message <- paste0("Warning: ", x$message)
  label_output(message, "warning")
}

#' @export
replay_html.message <- function(x, ...) {
  message <- gsub("\n$", "", x$message)
  label_output(message, "message")
}

#' @export
replay_html.error <- function(x, ...) {
  if (is.null(x$call)) {
    message <- paste0("Error: ", x$message)
  } else {
    call <- paste0(deparse(x$call), collapse = "")
    message <- paste0("Error in ", call, ": ", x$message)
  }
  label_output(message, "error")
}

#' @export
replay_html.recordedplot <- function(x, topic, obj_id, ...) {
  fig_save_default(x, fig_name(topic, obj_id))
}

#' @export
replay_html.knit_asis <- function(x, name_prefix, obj_id, ...) {
  # wrap in own div because <pre> breaks htmlwidgets stylesheet
  output <- htmltools::HTML(paste0("<div class='knit_asis'>", x, "</div>"))
  attr(output, "knit_meta") <- attr(x, "knit_meta")
  output
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
