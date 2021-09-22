test_that("urls to inherited methods of R6 classes are correctly modified ", {

  html <- c(
    "<span class=\"pkg-link\" data-pkg=\"R6test\" data-topic=\"Animal\" data-id=\"initialize\">",
    "<a href='../../R6test/html/Animal.html#method-initialize'><code>R6test::Animal$initialize()</code></a><code>R6test::Animal$initialize()</code></a>",
    "</span>"
  )

  result <- fix_R6_inherited_hrefs(html)

  expected_html <- c(
    "<span class=\"pkg-link\" data-pkg=\"R6test\" data-topic=\"Animal\" data-id=\"initialize\">",
    "<a href='Animal.html#method-initialize'><code>R6test::Animal$initialize()</code></a><code>R6test::Animal$initialize()</code></a>",
    "</span>"
  )

  expect_equal(result, expected_html)

  # html without class=\"pkg-link\" is unaffected
  html <- c(
    "<span class=\"something else\" data-pkg=\"R6test\" data-topic=\"Animal\" data-id=\"initialize\">",
    "<a href=\"../../R6test/html/Animal.html#method-initialize\"><code>R6test::Animal$initialize()</code></a><code>R6test::Animal$initialize()</code>",
    "</span>"
  )

  result <- fix_R6_inherited_hrefs(html)
  expect_equal(result, html)

})
