test_that("handles coc if present", {
  # .github is build-ignored to prevent a NOTE about unexpected hidden directory
  # so need to skip when run from R CMD check
  skip_if_not(dir_exists(test_path("assets/site-dot-github/.github")))

  pkg <- as_pkgdown(test_path("assets/site-dot-github"))
  expect_true(has_coc(pkg$src_path))

  # And added to sidebar
  text <- data_home_sidebar_community(pkg)
  expect_snapshot_output(cat(text))
})

test_that("empty site doesn't have community asserts", {
  expect_false(has_contributing(test_path("assets/site-empty")))
  expect_false(has_coc(test_path("assets/site-empty")))

  text <- data_home_sidebar_community(test_path("assets/site-empty"))
  expect_equal(text, "")
})
