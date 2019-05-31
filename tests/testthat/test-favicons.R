context("test-build-favicons.R")

test_that("missing logo generates message", {
  pkg <- test_path("assets/site-empty")
  on.exit(clean_site(pkg))

  pkg <- as_pkgdown(pkg)
  expect_message(
    build_favicons(pkg), "Can't find package logo"
  )
})

test_that("favicon is built from logo.png", {
  skip_on_cran() # requires internet connection
  skip_if_offline()

  pkg <- test_path("assets/site-favicons")

  pkg <- as_pkgdown(pkg)
  on.exit(dir_delete(path(pkg$src_path, "pkgdown")))

  favicon_path <- path(pkg$src_path, "pkgdown", "favicon")

  # create a new favicon
  expect_output(build_favicons(pkg))
  expect_true(file_exists(path(favicon_path, "favicon.ico")))
  fs::dir_delete(favicon_path)

  # create dummy favicon
  fs::dir_create(favicon_path)
  fs::file_touch(path(favicon_path, "favicon.ico"))

  # file exists but no clobber
  expect_message(
    build_favicons(pkg), "Favicons already exist"
  )

  # file exists, so clobber it
  expect_output(build_favicons(pkg, clobber = TRUE))
  expect_true(fs::file_size(favicon_path) > 0)
})
