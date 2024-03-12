
test_that("package_vignettes() doesn't trip over directories", {
  dir <- withr::local_tempdir()
  dir_create(path(dir, "vignettes", "test.Rmd"))
  file_create(path(dir, "vignettes", "test2.Rmd"))

  expect_equal(as.character(package_vignettes(dir)$file_in), "vignettes/test2.Rmd")
})

test_that("check_bootstrap_version() allows 3, 4 (with warning), and 5", {
  expect_equal(check_bootstrap_version(3), 3)
  expect_warning(expect_equal(check_bootstrap_version(4), 5))
  expect_equal(check_bootstrap_version(5), 5)
})

test_that("check_bootstrap_version() gives informative error otherwise", {
  local_edition(3)
  pkg <- local_pkgdown_site(test_path("assets/articles"))
  file_touch(file.path(pkg$src_path, "_pkgdown.yml"))

  expect_snapshot(check_bootstrap_version(1, pkg), error = TRUE)
})

test_that("package_vignettes() moves vignettes/articles up one level", {
  dir <- withr::local_tempdir()
  dir_create(path(dir, "vignettes", "articles"))
  file_create(path(dir, "vignettes", "articles", "test.Rmd"))

  pkg_vig <- package_vignettes(dir)
  expect_equal(as.character(pkg_vig$file_out), "articles/test.html")
  expect_equal(pkg_vig$depth, 1L)
})

test_that("package_vignettes() detects conflicts in final article paths", {
  dir <- withr::local_tempdir()
  dir_create(path(dir, "vignettes", "articles"))
  file_create(path(dir, "vignettes", "test.Rmd"))
  file_create(path(dir, "vignettes", "articles", "test.Rmd"))

  expect_error(package_vignettes(dir))
})

test_that("package_vignettes() sorts articles alphabetically by file name", {
  pkg <- local_pkgdown_site(test_path("assets/articles"))
  expect_equal(
    order(basename(pkg$vignettes$file_out)),
    seq_len(nrow(pkg$vignettes))
  )
})

test_that("override works correctly for as_pkgdown", {
  pkgdown <- as_pkgdown("assets/man-figures")
  expected_list <- list(figures = list(dev = "jpeg", fig.ext = "jpg", fig.width = 3, fig.asp = 1))
  expect_equal(pkgdown$meta, expected_list)
  modified_pkgdown <- as_pkgdown(pkgdown, override = list(figures = list(dev = "png")))
  modified_list <- list(figures = list(dev = "png", fig.ext = "jpg", fig.width = 3, fig.asp = 1))
  modified_pkgdown$meta
  expect_equal(modified_pkgdown$meta, modified_list)
})
# titles ------------------------------------------------------------------

test_that("multiline titles are collapsed", {
  rd <- rd_text("\\title{
    x
  }", fragment = FALSE)

  expect_equal(extract_title(rd), "x")
})

test_that("titles can contain other markup", {
  rd <- rd_text("\\title{\\strong{x}}", fragment = FALSE)
  expect_equal(extract_title(rd), "<strong>x</strong>")
})

test_that("titles don't get autolinked code", {
  rd <- rd_text("\\title{\\code{foo()}}", fragment = FALSE)
  expect_equal(extract_title(rd), "<code>foo()</code>")
})
