highlight_text <- function(text, pre_class = NULL) {
  out <- downlit::highlight(text, classes = downlit::classes_pandoc())
  if (!is.na(out)) {
    pre(out, r_code = TRUE, class = pre_class)
  } else {
    pre(escape_html(text), class = pre_class)
  }
}

highlight_examples <- function(code, topic, env = globalenv(), pre_class = NULL) {
  bg <- context_get("figures")$bg %||% NA
  withr::local_options(list(
    crayon.enabled = TRUE,
    crayon.colors = 256,
    device = function(...) ragg::agg_png(..., bg = bg)
  ))

  fig_save_topic <- function(plot, id) {
    name <- paste0(topic, "-", id)
    do.call(fig_save, c(list(plot, name), fig_settings()))
  }

  out <- downlit::evaluate_and_highlight(
    code,
    fig_save = fig_save_topic,
    env = child_env(env),
    output_handler = evaluate::new_output_handler(value = pkgdown_print)
  )
  pre(out, r_code = TRUE, class = pre_class)
}

pre <- function(x, r_code = FALSE, class = NULL) {
  paste0(
    "<pre", if (!is.null(class)) paste0(" class='", class, "'"), ">",
    if (r_code) "<code class='sourceCode R'>",
    x,
    if (r_code) "</code>",
    "</pre>"
  )
}
