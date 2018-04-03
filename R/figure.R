fig_name <- function(topic, obj_id) {
  paste0(topic, "-", obj_id(topic))
}

fig_save_default <- function(plot, name) {
  do.call(fig_save, c(list(plot, name), context_get("figures")))
}

fig_save <- function(plot,
                     name,
                     dev = "grDevices::png",
                     dpi = 96L,
                     dev.args = list(),
                     fig.ext = "png",
                     fig.width = 700 / 96,
                     fig.height = NULL,
                     fig.retina = 2L,
                     fig.asp = 1 / 1.618 # golden ratio
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

  with_device(dev, c(args, dev.args), plot)

  paste0(
    "<div class='img'>",
    "<img src='", escape_html(path), "' alt='' width='", width, "' height='", height, "' />",
    "</div>"
  )
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
  expr <- parse_expr(x)
  if (is_symbol(expr)) {
    x
  } else if (is_call(expr, "::")) {
    as.character(expr[[3]])
  } else {
    stop("Unknown input", call. = FALSE)
  }
}
