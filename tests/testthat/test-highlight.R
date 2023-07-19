test_that("highlight_examples captures dependencies", {
  withr::defer(unlink(test_path("Rplot001.png")))

  dummy_dep <- htmltools::htmlDependency("dummy", "1.0.0", "dummy.js")
  widget <- htmlwidgets::createWidget("test", list(), dependencies = dummy_dep)
  out <- highlight_examples("widget", env = environment())

  # htmlwidgets always get dependency on htmlwidgets.js
  expect_equal(attr(out, "dependencies")[-1], list(dummy_dep))
})

test_that("highlight_text & highlight_examples include sourceCode div", {
  withr::defer(unlink(test_path("Rplot001.png")))

  html <- xml2::read_html(highlight_examples("a + a", "x"))
  expect_equal(xpath_attr(html, "./body/div", "class"), "sourceCode")

  html <- xml2::read_html(highlight_text("a + a"))
  expect_equal(xpath_attr(html, "./body/div", "class"), "sourceCode")
})

test_that("pre() can produce needed range of outputs", {
  expect_snapshot({
    cat(pre("x"))
    cat(pre("x", r_code = TRUE))
  })
})

test_that("tweak_highlight_other() renders generic code blocks for roxygen2 >= 7.2.0", {
  div <- xml2::read_html('<div class="sourceCode"><pre><code>1+1\n</code></pre></div>') %>%
    xml2::xml_find_first("//div")
  tweak_highlight_other(div)
  expect_equal(
    xml2::xml_text(xml2::xml_find_first(div, "pre/code")),
    "1+1"
  )
})

test_that("tweak_highlight_other() renders nested code blocks for roxygen2 >= 7.2.0", {
  div <- xml2::read_html(
"<div class='sourceCode markdown'><pre><code>
blablabla

```{r results='asis'}
lalala
```

</code></pre></div>") %>%
    xml2::xml_find_first("//div")
  tweak_highlight_other(div)
  expect_match(
    xml2::xml_text(xml2::xml_find_first(div, "pre/code")),
    "```.?\\n"
  )
})
