context("test-html.R")

# find badges -------------------------------------------------------------

test_that("no paragraph", {
  expect_equal(badges_extract_text('<h1></h1>'), character())
})

test_that("no badges in paragraph", {
  expect_equal(badges_extract_text('<p></p>'), character())
})

test_that("finds single badge", {
  expect_equal(
    badges_extract_text('<p><a href="x"><img src="y"></a></p>'),
    '<a href="x"><img src="y"></a>'
  )
})

test_that("badges can't contain an extra text", {
  expect_equal(
    badges_extract_text('<p><a href="url"><img src="img" alt="alt" /></a>Hi!</p>'),
    character()
  )
})
