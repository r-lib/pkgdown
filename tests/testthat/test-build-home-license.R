context("test-build-home-license")

test_that("link_license matchs exactly", {
  # R 3.1 uses http url
  skip_if_not(getRversion() >= "3.2.0")

  # Shouldn't match first GPL-2
  expect_equal(
    autolink_license("LGPL-2"),
    "<a href='https://www.r-project.org/Licenses/LGPL-2'>LGPL-2</a>"
  )
})

test_that("link_license matches LICENSE", {
  expect_equal(
    autolink_license("LICENSE"),
    "<a href='LICENSE-text.html'>LICENSE</a>"
  )
})
