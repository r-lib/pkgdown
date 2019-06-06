context("test-build-home-community.R")

test_that("has_coc works", {
  # .github in this test is build-ignored to prevent a NOTE about an unexpected
  # hidden directory. Skip on CMD CHECK if the .github directory is not present.s
  skip_if_not(dir_exists(path(test_path("assets/site-dot-github"),
                              ".github"))[[1]])
  expect_true(has_coc(test_path("assets/site-dot-github")))
  expect_false(has_coc(test_path("assets/site-orcid")))
})

test_that("has_contributing works", {
  expect_false(has_contributing(test_path("assets/site-orcid")))
})

test_that("community section is added if COC present", {

  pkg <- test_path("assets/site-dot-github")

  # .github in this test is build-ignored to prevent a NOTE about an unexpected
  # hidden directory. Skip on CMD CHECK if the .github directory is not present.
  skip_if_not(dir_exists(path(pkg, ".github"))[[1]])

  comm <- data_home_sidebar_community(pkg)
  expect_equal(comm,
               "<div class='community'>\n<h2>Community</h2>\n<ul class='list-unstyled'>\n<li><a href=\"CODE_OF_CONDUCT.html\">Code of conduct</a></li>\n</ul>\n</div>\n")
})

test_that("community section is not added if no community files", {
  pkg <- test_path("assets/site-orcid")

  comm <- data_home_sidebar_community(pkg)

  expect_equal(comm, "")
})
