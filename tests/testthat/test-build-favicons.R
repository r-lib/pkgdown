context("test-build-favicons.R")

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
