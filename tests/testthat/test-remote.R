context("remote")

test_that("remote_package_url discovers pkgdown site", {
  expect_equal(
    remote_package_reference_url("pkgdown"),
    "http://hadley.github.io/pkgdown/reference"
  )
})

test_that("remote_package_url returns null in error scenarios", {
  expect_equal(remote_package_reference_url("DOESNOTEXIST"), NULL)
  # no urls
  expect_equal(remote_package_reference_url("cluster"), NULL)
  # not a pkgdown site
  expect_equal(remote_package_reference_url("MASS"), NULL)
})
