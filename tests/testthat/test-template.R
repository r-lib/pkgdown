context("templates")

# Make a copy of a test package so that we don't modify it in place
testdir <- tempdir()
file.copy(dir(test_path("home-readme-rmd"), full.names = TRUE), testdir)

test_that("init_yaml creates _pkgdown.yml", {
  yaml_file <- file.path(testdir, "_pkgdown.yml")
  expect_false(file.exists(yaml_file))
  init_yaml(testdir)
  expect_true(file.exists(yaml_file))
  yml <- readLines(yaml_file)
  expect_identical(yml[1], "navbar:")
})

test_that("init_yaml won't overwrite _pkgdown.yml", {
  expect_error(init_yaml(testdir), "_pkgdown.yml already exists")
})
