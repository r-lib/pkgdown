context("test-development.R")

test_that("empty yaml gets correct defaults", {
  dev <- meta_development(list())
  expect_equal(dev$mode, "release")
  expect_equal(dev$in_dev, FALSE)
  expect_equal(dev$version_label, "default")
})

test_that("mode = auto uses version", {
  dev <- meta_development(
    list(development = list(mode = "auto")),
    package_version("1.0.0.9000")
  )
  expect_equal(dev$mode, "devel")
  expect_equal(dev$in_dev, TRUE)
  expect_equal(dev$version_label, "danger")
})


test_that("dev_mode recognises basic version structure", {
  expect_equal(dev_mode(package_version("0.0.0.9000")), "unreleased")
  expect_equal(dev_mode(package_version("0.0.0.9001")), "unreleased")
  expect_equal(dev_mode(package_version("0.1.0")), "release")
  expect_equal(dev_mode(package_version("1.0.0.9000")), "devel")
})
