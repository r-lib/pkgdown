test_that("highlight_examples captures dependencies", {
  withr::defer(try(file_delete(test_path("Rplot001.png")), TRUE))

  dummy_dep <- htmltools::htmlDependency("dummy", "1.0.0", "dummy.js")
  widget <- htmlwidgets::createWidget("test", list(), dependencies = dummy_dep)
  out <- highlight_examples("widget", env = environment())

  # htmlwidgets always get dependency on htmlwidgets.js
  expect_equal(attr(out, "dependencies")[-1], list(dummy_dep))
})

test_that("highlight_examples runs and hides DONTSHOW calls()", {
  out <- highlight_examples("DONTSHOW(x <- 1)\nx")
  expect_snapshot(cat(strip_html_tags(out)))
})

test_that("highlight_text & highlight_examples include sourceCode div", {
  withr::defer(try(file_delete(test_path("Rplot001.png")), TRUE))

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
  html <- xml2::read_html('<div class="sourceCode"><pre><code>1+1\n</code></pre></div>')
  div <- xml2::xml_find_first(html, "//div")
    
  tweak_highlight_other(div)
  expect_equal(xpath_text(div, "pre/code"), "1+1")
})

test_that("tweak_highlight_other() renders nested code blocks for roxygen2 >= 7.2.0", {
  html <- xml2::read_html(dedent("
    <div class='sourceCode markdown'><pre><code>
    blablabla

    ```{r results='asis'}
    lalala
    ```

    </code></pre></div>
  "))
  div <- xml2::xml_find_first(html, "//div")

  tweak_highlight_other(div)
  expect_snapshot(cat(xpath_text(div, "pre/code")))
})
