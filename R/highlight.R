# highligh_text() and highlight_examples() are only used for usage
# and examples, and are specifically excluded in tweak_reference_highlighting()
highlight_text <- function(text) {
  out <- downlit::highlight(text, classes = downlit::classes_pandoc())
  if (!is.na(out)) {
    sourceCode(pre(out, r_code = TRUE))
  } else {
    sourceCode(pre(escape_html(text)))
  }
}

highlight_examples <- function(code, topic, env = globalenv()) {
  bg <- fig_settings()$bg %||% NA

  # some options from testthat::local_reproducible_output()
  # https://github.com/r-lib/testthat/blob/47935141d430e002070a95dd8af6dbf70def0994/R/local.R#L86
  withr::local_options(list(
    device = function(...) ragg::agg_png(..., bg = bg),
    rlang_interactive = FALSE,
    cli.num_colors = 256,
    cli.dynamic = FALSE
  ))
  withr::local_envvar(RSTUDIO = NA)
  withr::local_collate("C")

  fig_save_topic <- function(plot, id) {
    name <- paste0(topic, "-", id)
    do.call(fig_save, c(list(plot, name), fig_settings()))
  }

  hide_dontshow <- function(src, expr) {
    if (is.expression(expr)) {
      # evaluate 1.0.0
      if (length(expr) > 0) {
        hide <- is_call(expr[[1]], c("DONTSHOW", "TESTONLY"))
      } else {
        hide <- FALSE
      }
    } else if (is.call(expr)) {
      # evaluate 0.24.0
      hide <- is_call(expr, c("DONTSHOW", "TESTONLY"))
    } else {
      hide <- FALSE
    }

    if (hide) NULL else src
  }
  handler <- evaluate::new_output_handler(
    value = pkgdown_print,
    source = hide_dontshow
  )

  eval_env <- child_env(env)
  eval_env$DONTSHOW <- function(x) invisible(x)
  eval_env$TESTONLY <- function(x) invisible()

  out <- downlit::evaluate_and_highlight(
    code,
    fig_save = fig_save_topic,
    env = eval_env,
    output_handler = handler
  )
  structure(
    sourceCode(pre(out, r_code = TRUE)),
    dependencies = attr(out, "dependencies")
  )
}

pre <- function(x, r_code = FALSE) {
  paste0(
    "<pre", if (r_code) " class='sourceCode r'", ">", "<code>",
    x,
    "</code>","</pre>"
  )
}

sourceCode <- function(x) {
  paste0("<div class='sourceCode'>", x, "</div>")
}
