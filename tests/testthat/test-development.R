test_that("empty yaml gets correct defaults", {
  dev <- meta_development(list())
  expect_equal(dev$mode, "default")
  expect_equal(dev$in_dev, FALSE)
  expect_equal(dev$version_label, "default")
})

test_that("explicit devel status gets tooltip", {
  tooltip <- function(mode) {
    meta <- list(development = list(mode = mode))
    version <- package_version("1.0.0.9000")
    meta_development(meta, version)$version_tooltip
  }

  expect_equal(tooltip("auto"), "In-development version")
  expect_equal(tooltip("release"), "Released version")
  expect_equal(tooltip(NULL), "")
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

  expect_equal(dev_mode(package_version("0.0.1")), "release")

  expect_equal(dev_mode(package_version("0.1")), "release")
  expect_equal(dev_mode(package_version("0.1.0")), "release")
  expect_equal(dev_mode(package_version("0.1.9000")), "devel")

  expect_equal(dev_mode(package_version("1.0")), "release")
  expect_equal(dev_mode(package_version("1.0.0")), "release")
  expect_equal(dev_mode(package_version("1.0.0.9000")), "devel")
})
