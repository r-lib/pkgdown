fig_save <- function(plot,
                     name,
                     dev = "ragg::agg_png",
                     dpi = 96L,
                     dev.args = list(),
                     fig.ext = "png",
                     fig.width = 700 / 96,
                     fig.height = NULL,
                     fig.retina = 2L,
                     fig.asp = 1 / 1.618, # golden ratio
                     bg = NULL
                     ) {

  path <- paste0(name, ".", fig.ext)

  width <- round(dpi * fig.width)
  height <- round(dpi * fig.height)
  dev <- match_fun(dev)
  has_res <- "res" %in% names(formals(dev))
  if (has_res) {
    # raster device; units in pixels, need to rescale for retina
    args <- list(
      path, # some devices use file and some use filename
      width = width * fig.retina,
      height = height * fig.retina,
      res = dpi * fig.retina
    )
  } else {
    # vector device; units in inches; no need to rescale
    args <- list(
      path,
      width = fig.width,
      height = fig.height
    )
  }

  # NB: bg is always set to transparent here; it takes effect during
  # recording in highlight_examples()
  dev.args$bg <- NA

  with_device(dev, c(args, dev.args), plot)

  list(path = path, width = width, height = height)
}

meta_figures <- function(meta = list()) {
  # Avoid having two copies of the default settings
  default <- formals(fig_save)
  default$plot <- NULL
  default$name <- NULL
  default <- lapply(default, eval, baseenv())

  figures <- purrr::pluck(meta, "figures", .default = list())

  print_yaml(utils::modifyList(default, figures))
}

#! Get current settings for figures
#!
#' You will generally not need to use this unless you are handling
#' custom plot output.
#'
#' @return A list containing the entries from the `figures` field
#' in `_pkgdown.yaml` (see [build_reference]), with default values added.
#' Computed `width` and `height` values (in pixels) are also included.
#' @export
fig_settings <- function() {
  # Avoid having another copy of the default settings
  result <- formals(fig_save)
  result$plot <- NULL
  result$name <- NULL
  result <- lapply(result, eval, baseenv())

  settings <- context_get("figures")
  result[names(settings)] <- settings

  if (is.null(result$fig.height)) {
    result$fig.height <- with(result, fig.width * fig.asp)
  } else if (is.null(result$fig.width)) {
    result$fig.width <- with(result, fig.height / fig.asp)
  }
  result
}

with_device <- function(dev, dev.args, plot) {
  do.call(dev, dev.args)
  on.exit(grDevices::dev.off())

  print(plot)
}

fig_opts_chunk <- function(figures, default) {
  figures$dev <- fun_name(figures$dev)

  # fig.asp beats fig.height in knitr, so if it's provided only use
  # it to override the default height
  if (!is.null(figures$fig.asp) && is.null(figures$fig.height)) {
    figures$fig.height <- figures$fig.width * figures$fig.asp
    figures$fig.asp <- NULL
  }

  # Copy background into dev.args
  figures$dev.args <- figures$dev.args %||% list()
  figures$dev.args$bg <- figures$bg %||% NA

  utils::modifyList(default, figures)
}

# Find graphics device ----------------------------------------------------

match_fun <- function(x) {
  if (is.function(x)) {
    x
  } else if (is.character(x) && length(x) == 1) {
    e <- parse_expr(x)
    f <- eval(e, globalenv())

    if (!is.function(f)) {
      stop("`x` must evaluate to a function", call. = FALSE)
    }

    f
  } else {
    stop("`x` must be a function or string", call. = FALSE)
  }
}

# knitr only takes a function name - user will need to load package
fun_name <- function(x) {
  if (x == "ragg::agg_png") {
    return("ragg_png")
  }

  expr <- parse_expr(x)
  if (is_symbol(expr)) {
    x
  } else if (is_call(expr, "::")) {
    as.character(expr[[3]])
  } else {
    stop("Unknown input", call. = FALSE)
  }
}
