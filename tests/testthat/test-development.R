test_that("empty yaml gets correct defaults", {
  pkg <- local_pkgdown_site()
  expect_equal(pkg$development$mode, "default")
  expect_equal(pkg$development$in_dev, FALSE)
  expect_equal(pkg$development$version_label, "muted")
})

test_that("mode = auto uses version", {
  pkg <- local_pkgdown_site(
    desc = list(Version = "0.0.9000"),
    meta = list(development = list(mode = "auto"))
  )
  expect_equal(pkg$development$mode, "devel")
  expect_equal(pkg$development$in_dev, TRUE)
  expect_equal(pkg$development$version_label, "danger")
})

test_that("mode overrides version", {
  pkg <- local_pkgdown_site(
    desc = list(Version = "0.0.9000"),
    meta = list(development = list(mode = "release"))
  )

  expect_equal(pkg$development$mode, "release")
})

test_that("env var overrides mode", {
  withr::local_envvar("PKGDOWN_DEV_MODE" = "devel")
  pkg <- local_pkgdown_site(
    meta = list(development = list(mode = "release"))
  )
  expect_equal(pkg$development$mode, "devel")
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

test_that("validates yaml", {
  data_development_ <- function(...) {
    local_pkgdown_site(meta = list(...))
  }

  expect_snapshot(error = TRUE, {
    data_development_(development = 1)
    data_development_(development = list(mode = 1))
    data_development_(development = list(mode = "foo"))
    data_development_(development = list(destination = 1))
    data_development_(development = list(version_label = 1))
  })
})
