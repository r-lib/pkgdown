# index -------------------------------------------------------------------

test_that("can build site even if no Authors@R present", {
  skip_if_no_pandoc()

  pkg <- local_pkgdown_site(desc = list(
    Author = "Hadley Wickham",
    Maintainer = "Hadley Wickham <hadley@rstudio.com>",
    `Authors@R` = NA
  ))

  expect_no_error(suppressMessages(build_home_index(pkg)))
})

test_that("can build package without any index/readme", {
  pkg <- local_pkgdown_site()
  expect_no_error(suppressMessages(build_home_index(pkg)))
})

# .github files -----------------------------------------------------------

test_that(".github files are copied and linked", {
  skip_if_no_pandoc()

  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(pkg, ".github/404.md")
  pkg <- pkg_add_file(pkg, ".github/CODE_OF_CONDUCT.md")

  suppressMessages(build_home(pkg))

  lines <- read_lines(path(pkg$dst_path, "index.html"))
  expect_match(lines, 'href="CODE_OF_CONDUCT.html"', fixed = TRUE, all = FALSE)
  expect_true(file_exists(path(pkg$dst_path, "404.html")))
})
