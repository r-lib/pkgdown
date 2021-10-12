
# Add syntax highlighting to reference sections
tweak_reference_topic_html <- function(html) {
  switch_block_content <- function(block, highlighted_html) {
    xml2::xml_text(block) <- ""
      purrr::walk(highlighted_html, function(x) {xml2::xml_add_child(block, x) })
  }

  # blocks with language information = r
  r_blocks <- xml2::xml_find_all(html, "//div[contains(@class, 'sourceCode r')]/pre/code")
  # now add blocks with no language information
  nolang_r_blocks <- xml2::xml_find_all(html, "//div[contains(@class, 'ref-section')]/pre/code")

  highlight_r_block <- function(block) {
    out <- downlit::highlight(
      xml2::xml_text(block),
      classes = downlit::classes_pandoc()
    )
    if (!is.na(out)) {
      # Replace the original node contents with downlit output
      highlighted_html <- xml2::xml_contents(
        xml2::xml_find_first(xml2::read_html(out), "body")
      )
      switch_block_content(block, highlighted_html)
    }
  }

  purrr::walk(r_blocks, highlight_r_block)
  purrr::walk(nolang_r_blocks, highlight_r_block)

  # Blocks with language information set to something else than R
  # Select div's to keep the language information
  non_r_blocks <- xml2::xml_find_all(
    html,
    "//div[contains(@class, 'ref-section')]/div[contains(@class, 'sourceCode') and not(contains(@class, 'sourceCode r'))]"
  )

  highlight_other_block <- function(block) {
    lang <- sub("sourceCode ", "", xml2::xml_attr(block, "class"))
    code <- xml2::xml_text(xml2::xml_find_first(block, "pre/code"))
    out <- markdown_text(
      paste(c(sprintf("```%s", lang), code, "```"), collapse = "\n"),
      pkg = NULL
    )
    # Replace the original code contents with Pandoc's output
    highlighted_html <-  xml2::xml_contents(
      xml2::xml_find_first(out, "body/div/pre/code")
    )
    block <- xml2::xml_find_first(block, "pre/code")
    switch_block_content(block, highlighted_html)
  }

  purrr::walk(non_r_blocks, highlight_other_block)

  invisible(html)
}
