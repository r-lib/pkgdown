context("test-build-favicons.R")

test_that("bad logos generate a warning", {
  pkg <- as_pkgdown(test_path("assets/site-bad-logo"))
  on.exit(dir_delete(path(pkg$src_path, "pkgdown")))

  expect_warning(
    build_favicons_api(pkg),
    "Your logo file couldn't be processed"
  )
})
