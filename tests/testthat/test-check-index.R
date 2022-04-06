test_that("check fails if missing reference topics", {
  ref <- list(
    list(contents = c("a", "b"))
  )
  meta <- list(reference = ref)
  pkg <- as_pkgdown(test_path("assets/reference"), override = meta)

  withr::local_envvar(c(CI = "false"))
  expect_warning(check_index_missing(pkg), "Checking pkgdown index found errors")

  withr::local_envvar(c(CI = "true"))
  expect_error(check_index_missing(pkg), "Checking pkgdown index found errors")
})

test_that("check returns TRUE when successful for checking reference", {
  pkg <- as_pkgdown(test_path("assets/reference"))
  expect_true(check_index_missing(pkg, check_articles = FALSE))
})

test_that("check returns TRUE when successful for checking articles", {
  pkg <- local_pkgdown_site(test_path("assets/articles"))
  expect_true(check_index_missing(pkg, check_reference = FALSE))
})
