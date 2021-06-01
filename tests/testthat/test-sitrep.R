test_that("pkgdown_sitrep works", {
  # URL not in the pkgdown config
  pkg <- test_path("assets/figure")
  expect_snapshot(pkgdown_sitrep(pkg))
  # URL only in the pkgdown config
  pkg <- test_path("assets/cname")
  expect_snapshot(pkgdown_sitrep(pkg))
  # URL everywhere
  pkg <- test_path("assets/open-graph")
  expect_snapshot(pkgdown_sitrep(pkg))
})
