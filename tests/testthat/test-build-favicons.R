test_that("missing logo generates message", {
  pkg <- local_pkgdown_site()

  expect_snapshot(
    error = TRUE,
    expect_output(build_favicons(pkg), "Building favicons")
  )
})

test_that("existing logo generates message", {
  pkg <- local_pkgdown_site()
  dir_create(path(pkg$src_path, "pkgdown", "favicon"))
  file_create(path(pkg$src_path, "pkgdown", "favicon", "favicon.ico"))
  file_create(path(pkg$src_path, "logo.png"))

  expect_true(has_favicons(pkg))
  expect_snapshot(build_favicons(pkg))
})
