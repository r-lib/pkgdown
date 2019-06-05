context("test-build-home-community.R")

test_that("has_coc works", {
  expect_true(has_coc(test_path("assets/site-dot-github")))
  expect_false(has_coc(test_path("assets/site-orcid")))
})

test_that("has_contributing works", {
  expect_false(has_contributing(test_path("assets/site-dot-github")))
})

test_that("community section is added if COC present", {

  path <- test_path("assets/site-dot-github")
  skip_if_not(dir_exists(path(path, ".github"))[[1]])

  pkg <- as_pkgdown(path)

  comm <- data_home_sidebar_community(pkg)
  expect_equal(comm,
               "<div class='community'>\n<h2>Community</h2>\n<ul class='list-unstyled'>\n<li><a href=\"CODE_OF_CONDUCT.html\">Code of conduct</a></li>\n</ul>\n</div>\n")
})

test_that("community section is not added", {
  path <- test_path("assets/site-orcid")

  pkg <- as_pkgdown(path)

  comm <- data_home_sidebar_community(pkg)

  expect_equal(comm, "")
})
