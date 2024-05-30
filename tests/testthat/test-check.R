test_that("sitrep complains about BS3", {
  pkg <- local_pkgdown_site(
    test_path("assets/open-graph"),
    list(template = list(bootstrap = 3))
  )
  expect_snapshot(pkgdown_sitrep(pkg))
})

test_that("sitrep reports all problems", {
  pkg <- local_pkgdown_site(
    test_path("assets/reference"),
    list(reference = list(
      list(title = "Title", contents = c("a", "b", "c", "e"))
    ))
  )
  
  expect_snapshot(pkgdown_sitrep(pkg))
})

test_that("checks fails on first problem", {
  pkg <- local_pkgdown_site(
    test_path("assets/reference"),
    list(reference = list(
      list(title = "Title", contents = c("a", "b", "c", "e"))
    ))
  )
  
  expect_snapshot(check_pkgdown(pkg), error = TRUE)
})

test_that("both inform if everything is ok", {
  pkg <- test_path("assets/open-graph")
  expect_snapshot({
    pkgdown_sitrep(pkg)
    check_pkgdown(pkg)
  })
})

# check urls ------------------------------------------------------------------

test_that("check_urls reports problems", {
  # URL not in the pkgdown config
  pkg <- test_path("assets/figure")
  expect_snapshot(check_urls(pkg), error = TRUE)

  # URL only in the pkgdown config
  pkg <- test_path("assets/cname")
  expect_snapshot(check_urls(pkg), error = TRUE)
})
