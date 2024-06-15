test_that("handles CoC and SUPPORT if present", {
  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(pkg, ".github/SUPPORT.md")
  pkg <- pkg_add_file(pkg, ".github/CODE_OF_CONDUCT.md")

  expect_true(has_coc(pkg$src_path))
  expect_true(has_support(pkg$src_path))

  # And added to sidebar
  text <- data_home_sidebar_community(pkg)
  expect_snapshot_output(cat(text))
})

test_that("empty site doesn't have community asserts", {
  pkg <- local_pkgdown_site()

  expect_false(has_contributing(pkg$src_path))
  expect_false(has_coc(pkg$src_path))
  expect_equal(data_home_sidebar_community(pkg$src_path), "")
})
