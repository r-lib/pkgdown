context("build_article")

test_that("safe_file_copy (used in render_rmarkdown) copies files in subdirs", {
  tmp <- tempfile()
  d <- file.path(tmp, "some", "subdir")
  dirs <- c(tmp, d)
  dir_create(tmp)
  # Some setup: one dir exists, one doesn't
  expect_equivalent(dir_exists(dirs), c(TRUE, FALSE))

  file_to_copy <- "test-build-article.R"
  expect_identical(
    safe_file_copy(
      rep(test_path(file_to_copy), 2),
      file.path(dirs, file_to_copy)
    ),
    # path_expand because tempfile path has a double / that gets washed out
    path_expand(file.path(dirs, file_to_copy))
  )
})
