context("test-build-home-community.R")

test_that("community section is added if COC present", {
  skip_if_no_pandoc()
  skip_if_not(dir_exists(path(pkg, ".github"))[[1]])
  path <- test_path("assets/site-dot-github")

  expect_output(build_home(path))
  on.exit(clean_site(path))

  lines <- read_lines(path(path, "docs", "index.html"))
  expect_true(any(grepl('Code of conduct</a>',
                        lines)))
})

test_that("community section is not added", {
  path <- test_path("assets/site-orcid")

  expect_output(build_home(path))
  on.exit(clean_site(path))

  lines <- read_lines(path(path, "docs", "index.html"))
  expect_true(all(!grepl('<div class="community">',
                        lines)))
})
