test_that("empty yaml gets correct defaults", {
  dev <- meta_development(list())
  expect_equal(dev$mode, "default")
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

test_that("mode overrides version", {
  dev <- meta_development(
    list(development = list(mode = "release")),
    package_version("1.0.0.9000")
  )

  expect_equal(dev$mode, "release")
  expect_equal(dev$in_dev, FALSE)
  expect_equal(dev$version_label, "default")
})

test_that("dev_mode recognises basic version structure", {
  expect_equal(dev_mode_auto("0.0.0.9000"), "unreleased")

  expect_equal(dev_mode_auto("0.0.1"), "release")

  expect_equal(dev_mode_auto("0.1"), "release")
  expect_equal(dev_mode_auto("0.1.0"), "release")
  expect_equal(dev_mode_auto("0.1.9000"), "devel")

  expect_equal(dev_mode_auto("1.0"), "release")
  expect_equal(dev_mode_auto("1.0.0"), "release")
  expect_equal(dev_mode_auto("1.0.0.9000"), "devel")
})

test_that("can override dev_mode with env var", {
  withr::local_envvar("PKGDOWN_DEV_MODE" = "devel")
  expect_equal(dev_mode("1.0", list()), "devel")
})

test_that("bad mode yields good error", {
  expect_snapshot(check_mode("foo"), error = TRUE)
})
