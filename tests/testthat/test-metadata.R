context("test-metadata.R")

test_that("remote_package_url discovers pkgdown site", {
  skip_on_os("solaris")
  scoped_package_context("test")

  expect_equal(
    remote_package_reference_url("pkgdown"),
    "https://pkgdown.r-lib.org/reference"
  )
})

test_that("remote_package_url returns null in error scenarios", {
  scoped_package_context("test")

  expect_equal(remote_package_reference_url("DOESNOTEXIST"), NULL)
  # no urls
  expect_equal(remote_package_reference_url("cluster"), NULL)
  # not a pkgdown site
  expect_equal(remote_package_reference_url("MASS"), NULL)
})
