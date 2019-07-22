context("test-build-favicon.R")

test_that("build_favicon generates deprecation message", {
  pkg <- test_path("assets/site-favicons")
  pkg <- as_pkgdown(pkg)

  favicon_path <- path(pkg$src_path, "pkgdown", "favicon")
  on.exit(dir_delete(path(pkg$src_path, "pkgdown")))

  expect_message(
    expect_output(build_favicon(pkg)),
    "`build_favicon()` is deprecated",
    "Building favicons"
  )
})

test_that("missing logo generates message", {
  pkg <- test_path("assets/site-empty")
  on.exit(clean_site(pkg))

  pkg <- as_pkgdown(pkg)
  expect_error(
    expect_output(build_favicons(pkg)),
    "Can't find package logo"
  )
})

test_that("existing logo generates message", {
  pkg <- test_path("assets/site-favicons")
  pkg <- as_pkgdown(pkg)

  favicon_path <- path(pkg$src_path, "pkgdown", "favicon")

  on.exit(dir_delete(path(pkg$src_path, "pkgdown")))

  # create dummy favicon
  fs::dir_create(favicon_path)
  fs::file_touch(path(favicon_path, "favicon.ico"))

  expect_message(
    expect_output(build_favicons(pkg)),
    "Favicons already exist"
  )
})

test_that("favicons are built from logo.png", {
  skip_on_cran() # requires internet connection
  skip_on_travis()
  skip_if_offline()

  pkg <- test_path("assets/site-favicons")

  pkg <- as_pkgdown(pkg)
  favicon_path <- path(pkg$src_path, "pkgdown", "favicon")

  on.exit(dir_delete(path(pkg$src_path, "pkgdown")))

  expect_output(build_favicons(pkg))
  expect_true(file_exists(path(favicon_path, "favicon.ico")))
})


test_that("bad logos generate an error", {
  skip_on_cran() # requires internet connection
  skip_on_travis()
  skip_if_offline()

  pkg <- as_pkgdown(test_path("assets/site-bad-logo"))
  on.exit(dir_delete(path(pkg$src_path, "pkgdown")))

  expect_error(
    expect_output(build_favicons(pkg)),
    "Your logo file couldn't be processed"
  )
})

test_that("existing logo can be clobbered", {
  skip_on_cran() # requires internet connection
  skip_on_travis()
  skip_if_offline()

  pkg <- test_path("assets/site-favicons")
  pkg <- as_pkgdown(pkg)

  favicon_path <- path(pkg$src_path, "pkgdown", "favicon")

  on.exit(dir_delete(path(pkg$src_path, "pkgdown")))

  # create dummy favicon
  fs::dir_create(favicon_path)
  fs::file_touch(path(favicon_path, "favicon.ico"))

  # file exists, but ensure we can overwrite
  expect_output(build_favicons(pkg, overwrite = TRUE))
  expect_true(fs::file_size(favicon_path) > 0)
})
