context("build")

test_that("the package docs are built", {
  site_path <- tempfile("staticdocs-site-")
  dir.create(site_path)
  on.exit(unlink(site_path, recursive = TRUE))

  pkg <- as.sd_package("../..", site_path)

  topics <- build_topics(pkg)

  expect_is(topics, "data.frame")
  expect_gte(nrow(topics), 1L)
  expect_named(topics, c("name", "alias", "file_in", "file_out", "title", "in_index"))

  expect_identical(topics$file_out %in% dir(site_path), rep(TRUE, length(topics$file_out)))
})
