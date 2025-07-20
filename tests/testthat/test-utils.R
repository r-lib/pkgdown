test_that("is_internal_link() works", {
  pkg = list(meta = list(url = "https://pkgdown.r-lib.org"))
  expect_false(is_internal_link("https://github.com", pkg = pkg))
  expect_false(is_internal_link("http://github.com", pkg = pkg))
  expect_true(is_internal_link("https://pkgdown.r-lib.org/articles", pkg = pkg))
  expect_true(is_internal_link("reference/index.html", pkg = pkg))
  expect_true(
    all.equal(
      is_internal_link(
        c("reference/index.html", "https://github.com"),
        pkg = pkg
      ),
      c(TRUE, FALSE)
    )
  )
})
