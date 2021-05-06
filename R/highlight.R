highlight_text <- function(text) {
  out <- downlit::highlight(text, classes = downlit::classes_pandoc())
  if (!is.na(out)) {
    paste0('<pre><code class="sourceCode R">', out, '</code></pre>')
  } else {
    paste0('<pre>', escape_html(text), '</pre>')
  }
}

highlight_examples <- function(code, topic, env = globalenv()) {
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
  paste0('<pre><code class="sourceCode R">', out, '</code></pre>')
}
