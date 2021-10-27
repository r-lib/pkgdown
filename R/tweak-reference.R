# Syntax highlighting for `\preformatted{}` blocks in reference topics
tweak_reference_highlighting <- function(html) {
  # We only process code inside ref-section since examples and usage are
  # handled elsewhere
  base <- find_ref_sections(html)

  # There are three cases:
  # 1) <div> with class sourceCode + r/R, as created by ```R
  div <- xml2::xml_find_all(base, ".//div")
  div_sourceCode <- div[has_class(div, "sourceCode")]
  is_r <- has_class(div_sourceCode, c("r", "R"))
  div_sourceCode_r <- div_sourceCode[is_r]
  purrr::walk(div_sourceCode_r, tweak_highlight_r)

  # 2) <div> with class sourceCode + another language, e.g. ```yaml
  div_sourceCode_other <- div_sourceCode[!is_r]
  purrr::walk(div_sourceCode_other, tweak_highlight_other)

  # 3) <pre> with no wrapper <div>, as created by ```
  pre <- xml2::xml_find_all(base, ".//pre")
  is_wrapped <- is_wrapped_pre(pre)
  purrr::walk(pre[!is_wrapped], tweak_highlight_r)

  invisible()
}

is_wrapped_pre <- function(html) {
  xml2::xml_find_lgl(html, "boolean(parent::div[contains(@class, 'sourceCode')])")
}

find_ref_sections <- function(html) {
  xml2::xml_find_all(html, ".//div[@id='ref-sections']")
}

tweak_highlight_r <- function(block) {
  code <- xml2::xml_find_first(block, ".//code")
  if (is.na(code)) {
    return(FALSE)
  }

  text <- xml2::xml_text(code)
  out <- downlit::highlight(text, classes = downlit::classes_pandoc())
  if (is.na(out) || identical(out, "")) {
    return(FALSE)
  }

  html <- xml2::read_html(out)
  xml_replace_contents(code, xml2::xml_find_first(html, "body"))

  TRUE
}

tweak_highlight_other <- function(div) {
  code <- xml2::xml_find_first(div, ".//code")
  if (is.na(code)) {
    return(FALSE)
  }

  lang <- sub("sourceCode ", "", xml2::xml_attr(div, "class"))
  md <- paste0("```", lang, "\n", xml2::xml_text(code), "\n```")
  html <- markdown_text(md)

  xml_replace_contents(code, xml2::xml_find_first(html, "body/div/pre/code"))
  TRUE
}

xml_replace_contents <- function(node, new) {
  xml2::xml_remove(xml2::xml_contents(node))

  contents <- xml2::xml_contents(new)
  for (child in contents) {
    xml2::xml_add_child(node, child)
  }
}
