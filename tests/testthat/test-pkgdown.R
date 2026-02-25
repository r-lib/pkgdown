test_that("in_pkgdown_pkg() works", {
  expect_false(in_pkgdown())
  expect_false(in_pkgdown_pkg("testpackage"))

  pkg <- local_pkgdown_site()
  local_envvar_pkgdown(pkg)

  expect_true(in_pkgdown())
  expect_false(in_pkgdown_pkg("pkgdown"))
  expect_true(in_pkgdown_pkg("testpackage"))
})
