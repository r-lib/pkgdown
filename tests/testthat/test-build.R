test_that("both versions of build_site have same arguments", {
  expect_equal(formals(build_site_local), formals(build_site_external))
})

test_that("build_site can be made unquiet", {
  pkg <- local_pkgdown_site(test_path("assets/articles-images"))
  expect_snapshot(build_site(pkg, quiet = FALSE))
})
