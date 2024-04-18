test_that("can find files in root and .github", {
  dir <- withr::local_tempdir()
  dir_create(path(dir, ".github"))
  file_create(path(dir, "a.md"))
  file_create(path(dir, ".github", "b.md"))

  mds <- withr::with_dir(dir, package_mds("."))
  expect_equal(mds, c("a.md", "./.github/b.md"))
})

test_that("drops files handled elsewhere", {
  dir <- withr::local_tempdir()
  dir_create(path(dir, ".github"))
  file_create(path(dir, c("README.md", "LICENSE.md", "NEWS.md")))

  expect_equal(withr::with_dir(dir, package_mds(".")), character())
})

test_that("drops files that don't need to be rendered", {
  dir <- withr::local_tempdir()
  dir_create(path(dir, ".github"))
  file_create(path(dir, c("cran-comments.md", "issue_template.md")))

  expect_equal(withr::with_dir(dir, package_mds(".")), character())
})



