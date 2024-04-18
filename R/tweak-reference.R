# Syntax highlighting for `\preformatted{}` blocks in reference topics
tweak_reference_highlighting <- function(html) {
  # There are three cases:
  # 1) <div> with class sourceCode + r/R, as created by ```R
  div <- xml2::xml_find_all(html, ".//div")
  # must have sourceCode and not be in examples or usage
  is_source <- has_class(div, "sourceCode") & !is_handled_section(div)

  div_sourceCode <- div[is_source]
  is_r <- has_class(div_sourceCode, c("r", "R"))
  div_sourceCode_r <- div_sourceCode[is_r]
  purrr::walk(div_sourceCode_r, tweak_highlight_r)

  # 2) <div> with class sourceCode + another language, e.g. ```yaml
  # or no language e.g. ```
  div_sourceCode_other <- div_sourceCode[!is_r]
  purrr::walk(div_sourceCode_other, tweak_highlight_other)

  # 3) <pre> with no wrapper <div>, as created by ```
  pre <- xml2::xml_find_all(html, ".//pre")
  handled <- is_wrapped_pre(pre) | is_handled_section(pre)
  purrr::walk(pre[!handled], tweak_highlight_r)
  # Add div.sourceCode for copy button
  xml2::xml_add_parent(pre[!handled], "div", class = "sourceCode")

  invisible()
}

is_wrapped_pre <- function(html) {
  xml2::xml_find_lgl(html, "boolean(parent::div[contains(@class, 'sourceCode')])")
}

is_handled_section <- function(html) {
  xml2::xml_find_lgl(html, "boolean(ancestor::div[@id='ref-examples' or @id='ref-usage'])")
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
  # since roxygen 7.2.0 generic code blocks have sourceCode with no lang
  if (!is.na(lang) && lang == "sourceCode") lang <- "r"
  # Pandoc does not recognize rmd as a language :-)
  if (tolower(lang) %in% c("rmd", "qmd")) lang <- "markdown"
  # many backticks to account for possible nested code blocks
  # like a Markdown code block with code chunks inside
  md <- paste0("``````", lang, "\n", xml2::xml_text(code), "\n``````")
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


tweak_extra_logo <- function(html) {
  img <- xml2::xml_find_all(html, ".//div[contains(@class,'ref-description')]//img[contains(@src,'logo')]")
  xml2::xml_remove(img)

  invisible()
}
