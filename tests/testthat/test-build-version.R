context("test-build-version.R")

test_that("formatting in DESCRIPTION version is preserved", {
  pkg <- as_pkgdown(test_path("assets/version-formatting"))
  expect_equal(pkg$version, "1.0.0-9000")

  expect_output(init_site(pkg))
  build_home_index(pkg, quiet = TRUE)
  index <- read_lines(path(pkg$dst_path, "index.html"))
  expect_true(any(grepl("1.0.0-9000", index, fixed = TRUE)))
})
