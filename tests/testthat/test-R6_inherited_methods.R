test_that("urls to inherited methods of R6 classes are correctly modified ", {
  skip_if_no_pandoc()
  withr::local_temp_libpaths()

  R6 <- test_path("assets/R6-inherited-methods")
  on.exit(clean_site(R6))

  callr::rcmd("INSTALL", R6, show = TRUE, fail_on_status = TRUE)

  expect_output(build_reference(R6, devel = FALSE))
  html <- path(R6, "docs", "reference", "Dog.html")

  lines <- read_lines(html)
  lines <- lines[grep("class=\"pkg-link\"", lines, fixed = TRUE)]

  hrefs <- vapply(regmatches(lines, regexec("<a href='(.*?)'", lines)), `[[`, character(1L), 2L)

  # or perhaps test if the url does not start with "../../pkgname/html/"
  expect_identical(hrefs, "Animal.html#method-initialize")
})
