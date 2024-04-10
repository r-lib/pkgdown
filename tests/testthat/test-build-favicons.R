test_that("missing logo generates message", {
  pkg <- local_pkgdown_site(test_path("assets/site-empty"))

  expect_snapshot(error = TRUE,
    expect_output(build_favicons(pkg), "Building favicons")
  )
})

test_that("existing logo generates message", {
  pkg <- local_pkgdown_site(test_path("assets/site-favicons"))

  expect_true(has_favicons(pkg))
  expect_snapshot(build_favicons(pkg))
})
