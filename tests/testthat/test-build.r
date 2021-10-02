test_that("both versions of build_site have same arguments", {
  expect_equal(formals(build_site_local), formals(build_site_external))
})

test_that("can build package without any index/readme", {
  pkg <- test_path("assets/site-empty")
  on.exit(clean_site(pkg))

  expect_output(build_site(pkg))
})
