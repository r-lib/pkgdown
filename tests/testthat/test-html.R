context("test-html.R")

# find badges -------------------------------------------------------------

test_that("finds single badge", {
  expect_length(
    badges_extract('<p><a href="url"><img src="img" alt="alt" /></a></p>'),
    1
  )
})

test_that("no badges paragraph", {
  expect_length(
    badges_extract(xml2::xml_missing()),
    0
  )
})

test_that("badges can't contain an extra text", {
  expect_length(
    badges_extract('<p><a href="url"><img src="img" alt="alt" /></a>Hi!</p>'),
    0
  )
})
