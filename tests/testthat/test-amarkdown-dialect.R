context("test-markdown-dialect.R")

test_that("markdown inside html block gets parsed", {
  skip_if_not(rmarkdown::pandoc_available('2.0'))

  pkg <- test_path("assets/markdown-dialect")
  expect_output(build_home(pkg))
  on.exit(clean_site(pkg))

  lines <- read_lines(path(pkg, "docs", "index.html"))
  expect_true(any(grepl('<details>', lines, fixed = TRUE)))
  expect_true(any(grepl('Some header</h2>', lines, fixed = TRUE)))
  expect_true(any(grepl('<span class="dv">123</span>', lines, fixed = TRUE)))
})
