# index -------------------------------------------------------------------

test_that("intermediate files cleaned up automatically", {
  skip_if_no_pandoc()

  pkg <- local_pkgdown_site(test_path("assets/home-index-rmd"))
  suppressMessages(init_site(pkg))
  suppressMessages(build_home(pkg))

  expect_setequal(path_file(dir_ls(pkg$src_path)), c("DESCRIPTION", "index.Rmd"))
})

test_that("intermediate files cleaned up automatically", {
  skip_if_no_pandoc()

  pkg <- local_pkgdown_site(test_path("assets/home-readme-rmd"))
  suppressMessages(init_site(pkg))
  suppressMessages(build_home(pkg))

  expect_setequal(
    path_file(dir_ls(pkg$src_path)),
    c("NAMESPACE", "DESCRIPTION", "README.md", "README.Rmd")
  )
})

test_that("can build site even if no Authors@R present", {
  skip_if_no_pandoc()

  pkg <- local_pkgdown_site(test_path("assets/home-old-skool"))
  suppressMessages(init_site(pkg))
  expect_no_error(suppressMessages(build_home(pkg)))
})

test_that("can build package without any index/readme", {
  pkg <- local_pkgdown_site()
  expect_no_error(suppressMessages(build_home(pkg)))
})

# .github files -----------------------------------------------------------

test_that(".github files are copied and linked", {
  skip_if_no_pandoc()
  # .github is build-ignored to prevent a NOTE about unexpected hidden directory
  # so need to skip when run from R CMD check
  skip_if_not(dir_exists(test_path("assets/site-dot-github/.github")))

  pkg <- local_pkgdown_site(test_path("assets/site-dot-github"))
  suppressMessages(init_site(pkg))
  suppressMessages(build_home(pkg))

  lines <- read_lines(path(pkg$dst_path, "index.html"))
  expect_true(any(grepl('href="CODE_OF_CONDUCT.html"', lines)))
  expect_true(file_exists(path(pkg$dst_path, "404.html")))
})
