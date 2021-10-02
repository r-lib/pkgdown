test_that("doesn't find badges when they don't exist", {
  expect_equal(badges_extract_text("<h1></h1>"), character())
  expect_equal(badges_extract_text("<p></p>"), character())

  # first paragraph contains non-image components
  expect_equal(
    badges_extract_text('<p><a href="url"><img src="img" alt="alt" /></a>Hi!</p>'),
    character()
  )
})

test_that("finds single badge", {
  expect_equal(
    badges_extract_text('<p><a href="x"><img src="y"></a></p>'),
    '<a href="x"><img src="y"></a>'
  )
})

test_that("finds badges in #badges div", {
  expect_equal(
    badges_extract_text('<p></p><div id="badges"><a href="x"><img src="y"></a></div>'),
    '<a href="x"><img src="y"></a>'
  )

  # even if there's extra text
  expect_equal(
    badges_extract_text('<p></p><p><div id="badges"><a href="x"><img src="y"></a>Hi!</div></p>'),
    '<a href="x"><img src="y"></a>'
  )
})

test_that("can find badges in comments", {
  html <- '
    <!-- badges: start -->
    <p><a href="x"><img src="y"></a></p>
    <!-- badges: end -->
  '
  expect_equal(badges_extract_text(html), '<a href="x"><img src="y"></a>')

  # produced by usethis
  html <- '
    <!-- badges: start -->
    <p><a href="x"><img src="y"></a>
    <!-- badges: end -->
    </p>
  '
  expect_equal(badges_extract_text(html), '<a href="x"><img src="y"></a>')
})

test_that("ignores extraneous content", {
  html <- '
    <!-- badges: start -->
    <p><a href="x"><img src="y"></a></p>
    <p>a</p>
    <p><a href="b.html">B</a></p>
    <!-- badges: end -->
  '
  expect_equal(badges_extract_text(html), '<a href="x"><img src="y"></a>')
})
