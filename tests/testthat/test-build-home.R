# index -------------------------------------------------------------------

test_that("intermediate files cleaned up automatically", {
  skip_if_no_pandoc()

  pkg <- local_pkgdown_site(test_path("assets/home-index-rmd"))
  expect_output(build_home(pkg))

  expect_setequal(dir(pkg$src_path), c("DESCRIPTION", "index.Rmd"))
})

test_that("intermediate files cleaned up automatically", {
  skip_if_no_pandoc()

  pkg <- local_pkgdown_site(test_path("assets/home-readme-rmd"))
  expect_output(build_home(pkg))

  expect_setequal(
    dir(pkg$src_path),
    c("NAMESPACE", "DESCRIPTION", "README.md", "README.Rmd")
  )
})

test_that("warns about missing images", {
  skip_if_not_installed("rlang", "0.99")
  pkg <- local_pkgdown_site(test_path("assets/bad-images"))
  expect_snapshot(build_home(pkg))
})

test_that("can build site even if no Authors@R present", {
  skip_if_no_pandoc()

  pkg <- local_pkgdown_site(test_path("assets/home-old-skool"))
  expect_output(build_home(pkg))
})

# .github files -----------------------------------------------------------

test_that(".github files are copied and linked", {
  skip_if_no_pandoc()
  # .github is build-ignored to prevent a NOTE about unexpected hidden directory
  # so need to skip when run from R CMD check
  skip_if_not(dir_exists(test_path("assets/site-dot-github/.github")))

  pkg <- local_pkgdown_site(test_path("assets/site-dot-github"))
  expect_output(build_home(pkg))

  lines <- read_lines(path(pkg$dst_path, "index.html"))
  expect_true(any(grepl('href="CODE_OF_CONDUCT.html"', lines)))
  expect_true(file_exists(path(pkg$dst_path, "404.html")))
})
