fig_save <- function(
  plot,
  name,
  dev = "ragg::agg_png",
  dpi = 96L,
  dev.args = list(),
  fig.ext = "png",
  fig.width = 700 / 96,
  fig.height = NULL,
  fig.retina = 2L,
  fig.asp = 1 / 1.618, # golden ratio
  bg = NULL,
  other.parameters = list()
) {
  path <- paste0(name, ".", fig.ext)
  dev <- match_fun(dev)

  if (is.null(fig.height)) {
    fig.height <- fig.width * fig.asp
  } else if (is.null(fig.width)) {
    fig.width <- fig.height / fig.asp
  }
  width <- round(dpi * fig.width)
  height <- round(dpi * fig.height)

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

fig_save_args <- function() {
  # Avoid having multiple copies of the default settings
  default <- formals(fig_save)
  default$plot <- NULL
  default$name <- NULL
  default <- lapply(default, eval, baseenv())
  default
}

meta_figures <- function(pkg) {
  default <- fig_save_args()
  figures <- config_pluck_list(pkg, "figures")

  print_yaml(modify_list(default, figures))
}

#' Get current settings for figures
#'
#' @description
#' You will generally not need to use this function unless you are handling
#' custom plot output.
#'
#' Packages needing custom parameters should ask users to place them within
#' the `other.parameters` entry under the package name, e.g.
#' ```
#' figures:
#'   other.parameters:
#'     rgl:
#'       fig.asp: 1
#' ```
#'
#' @return
#' A list containing the entries from the `figures` field in `_pkgdown.yml`
#' (see [build_reference()]), with default values added. Computed `width` and
#' `height` values (in pixels) are also included.
#' @export
#' @keywords internal
fig_settings <- function() {
  result <- fig_save_args()

  # The context might not be initialized.
  settings <- tryCatch(context_get("figures"), error = function(e) NULL)
  result[names(settings)] <- settings

  if (is.null(result$fig.height)) {
    result$fig.height <- result$fig.width * result$fig.asp
  } else if (is.null(result$fig.width)) {
    result$fig.width <- result$fig.height / result$fig.asp
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

  # Default figure class for rendered images
  # Same class as added by downlit
  figures$fig.class <- figures$fig.class %||% "r-plt"

  modify_list(default, figures)
}

# Find graphics device ----------------------------------------------------

match_fun <- function(x) {
  if (is.function(x)) {
    x
  } else if (is.character(x) && length(x) == 1) {
    e <- parse_expr(x)
    f <- eval(e, globalenv())

    if (!is.function(f)) {
      cli::cli_abort(
        "{.var x} must evaluate to a function",
        call = caller_env()
      )
    }

    f
  } else {
    cli::cli_abort("{.var x} must be a function or string", call = caller_env())
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
    cli::cli_abort("Unknown input", call = caller_env())
  }
}
