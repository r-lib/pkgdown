test_that("is_pkgdown checks its inputs", {
  expect_snapshot(error = TRUE, {
    as_pkgdown(1)
    as_pkgdown(override = 1)
  })

})

test_that("package_vignettes() doesn't trip over directories", {
  dir <- withr::local_tempdir()
  dir_create(path(dir, "vignettes", "test.Rmd"))
  file_create(path(dir, "vignettes", "test2.Rmd"))

  expect_equal(as.character(package_vignettes(dir)$file_in), "vignettes/test2.Rmd")
})

test_that("check_bootstrap_version() allows 3, 4 (with warning), and 5", {
  pkg <- local_pkgdown_site()

  expect_equal(check_bootstrap_version(3, pkg), 3)
  expect_snapshot(expect_equal(check_bootstrap_version(4, pkg), 5))
  expect_equal(check_bootstrap_version(5, pkg), 5)
})

test_that("check_bootstrap_version() gives informative error otherwise", {
  pkg <- local_pkgdown_site()
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
  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(pkg, "vignettes/a.Rmd")
  pkg <- pkg_add_file(pkg, "vignettes/b.Rmd")
  pkg <- pkg_add_file(pkg, "vignettes/c.Rmd")

  expect_equal(
    path_file(pkg$vignettes$file_out),
    c("a.html", "b.html", "c.html")
  )
})

test_that("override works correctly for as_pkgdown", {
  pkg1 <- local_pkgdown_site(meta = list(figures = list(dev = "jpeg")))
  pkg2 <- as_pkgdown(pkg1, override = list(figures = list(dev = "png")))
  expect_equal(pkg2$meta$figures$dev, "png")
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

test_that("read_meta() errors gracefully if _pkgdown.yml failed to parse", {
  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(pkg, "_pkgdown.yml", c(
    "url: https://pkgdown.r-lib.org",
    "  title: Build websites for R packages"
  ))
  expect_snapshot(
    as_pkgdown(pkg$src_path),
    error = TRUE,
    transform = function(x) gsub(pkg$src_path, "<src>", x, fixed = TRUE)
  )
})

# lifecycle ---------------------------------------------------------------

test_that("can extract lifecycle badges from description", {
  rd_desc <- rd_text(
    paste0("\\description{", lifecycle::badge("deprecated"), "}"),
    fragment = FALSE
  )
  rd_param <- rd_text(
    paste0("\\arguments{\\item{pkg}{", lifecycle::badge("deprecated"), "}}"),
    fragment = FALSE
  )

  expect_equal(extract_lifecycle(rd_desc), "deprecated")
  expect_equal(extract_lifecycle(rd_param), NULL)
})

test_that("malformed figures fail gracefully", {
  rd_lifecycle <- function(x) extract_lifecycle(rd_text(x))

  expect_null(rd_lifecycle("{\\figure{deprecated.svg}}"))
  expect_null(rd_lifecycle("{\\figure{}}"))
})
