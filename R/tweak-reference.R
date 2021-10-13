# Syntax highlight for preformatted code blocks
tweak_reference_highlighting <- function(html) {
  # We only process code inside ref-section since examples and usage are
  # handled elsewhere
  base <- xml2::xml_find_all(html, "//div[contains(@class, 'ref-section')]")

  # There are three cases:
  # 1) <pre> with no wrapper <div>, as created by ```
  pre_unwrapped <- xml2::xml_find_all(base, "//pre")
  purrr::walk(pre_unwrapped, tweak_highlight_r)

  div <- xml2::xml_find_all(base, "//div")
  div_sourceCode <- div[has_class(div, "sourceCode")]
  # 2) <div> with class sourceCode + R, as created by ```R
  div_sourceCode_r <- div_sourceCode[has_class(div_sourceCode, "r")]
  purrr::walk(div_sourceCode_r, tweak_highlight_r)

  # 3) <div> with class sourceCode + another language, e.g. ```yaml
  div_sourceCode_other <- div_sourceCode[!has_class(div_sourceCode, "r")]
  purrr::walk(div_sourceCode_other, tweak_highlight_other)

  invisible()
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
    return()
  }

  lang <- sub("sourceCode ", "", xml2::xml_attr(div, "class"))
  md <- paste0("```", lang, "\n", xml2::xml_text(code), "\n```")
  html <- markdown_text(md)

  xml_replace_contents(code, xml2::xml_find_first(html, "body/div/pre/code"))
  invisible()
}

xml_replace_contents <- function(node, new) {
  xml2::xml_remove(xml2::xml_contents(node))

  contents <- xml2::xml_contents(new)
  for (child in contents) {
    xml2::xml_add_child(node, child)
  }
}
