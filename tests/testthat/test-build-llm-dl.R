test_that("single dt/dd pair converts to simple li", {
  html <- xml2::read_html("<dl></dl>")
  simplify_dls(html)

  expect_equal(xpath_length(html, ".//dl"), 0)
  expect_equal(xpath_length(html, ".//ul"), 1)
})

test_that("single dt/dd pair converts to simple li", {
  html <- xml2::read_html(
    "<dl>
        <dt>a</dt>
        <dd>b</dd>
      </dl>"
  )
  simplify_dls(html)

  expect_equal(xpath_length(html, ".//dl"), 0)
  expect_equal(xpath_text(html, ".//li"), "a: b")
})

test_that("dd with block elements simplifies correctly", {
  html <- xml2::read_html(
    "<dl>
        <dt>a</dt>
        <dd>
          <p>b</p>
          <p>c</p>
        </dd>
      </dl>"
  )
  simplify_dls(html)

  expect_equal(xpath_length(html, ".//dl"), 0)
  expect_equal(xpath_length(html, ".//ul"), 1)
  expect_snapshot(xpath_xml(html, ".//li"))
})

test_that("warns if not applied", {
  html <- xml2::read_html(
    "
      <dl>
        <dt>a</dt>
      </dl>
  "
  )
  expect_snapshot(. <- simplify_dls(html))
})

test_that("correctly detects simple dls", {
  expect_false(is_simple_dl("dt"))
  expect_false(is_simple_dl(c("dd", "dt")))
  expect_false(is_simple_dl(c("dt", "dd", "dt")))
  expect_false(is_simple_dl(c("dd", "dt", "dd", "dt")))

  expect_true(is_simple_dl(c()))
  expect_true(is_simple_dl(c("dt", "dd")))
  expect_true(is_simple_dl(c("dt", "dd", "dt", "dd")))
})
