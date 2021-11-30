test_that("ORCID can be identified from all comment styles", {
  desc <- desc::desc(text = c(
    'Authors@R: c(',
    '    person("test no comment"),',
    '    person("test comments no orcid", comment = c("test comment no orcid")),',
    '    person("test bare comment", comment = "test bare comment"),',
    '    person("test orcid only", comment = c(ORCID = "1")),',
    '    person("test comment and orcid", comment = c("test comment and orcid", ORCID = "2"))',
    '  )'
  ))
  authors <- unclass(desc$get_authors())
  authors <- purrr::map(authors, author_list, list(), pkg = list())
  orcid <- purrr::map(authors, "orcid")
  expect_equal(orcid, list(NULL, NULL, NULL, orcid_link("1"), orcid_link("2")))
})

test_that("names can be removed from persons", {
  remove_orcid <- function(comment) {
    remove_name(comment, "ORCID")
  }
  expect_equal(remove_orcid(NULL), NULL)
  expect_equal(remove_orcid("one"), "one")
  expect_equal(remove_orcid(c("one", "two")), c("one", "two"))
  expect_equal(remove_orcid(c("one", ORCID = "orcid")), "one")
  expect_equal(remove_orcid(c(ORCID = "orcid")), character())
  expect_equal(remove_orcid(c(ORCID = "orcid1", ORCID = "orcid2")), character())
})

test_that("author comments linkified", {
  p <- list(name = "Jane Doe", roles = "rev", comment = "<https://x.org/>")
  expect_match(author_desc(p), linkify("<https://x.org/>"), fixed = TRUE)
})

test_that("Data authors can accept different filtering", {
  pkg <- as_pkgdown(test_path("assets/sidebar"))
  expect_length(data_authors(pkg)$main, 2)
  expect_length(data_authors(pkg, roles = "cre")$main, 1)
})

test_that("Text can be added", {
  pkg <- as_pkgdown(test_path("assets/sidebar-comment"))
  expect_null(data_authors_page(pkg)$after)
  expect_null(data_authors_page(pkg)$before)

  pkg$meta$authors$before <- "Dream team:"
  pkg$meta$authors$after <- "You are welcome!"
  expect_equal(data_authors_page(pkg)$before, "<p>Dream team:</p>")
  expect_equal(data_authors_page(pkg)$after, "<p>You are welcome!</p>")
})

test_that("data_home_sidebar_authors() works with text", {
  pkg <- as_pkgdown(test_path("assets/sidebar-comment"))
  pkg$meta$authors$sidebar$before <- "yay"
  pkg$meta$authors$sidebar$after <- "cool"
  expect_snapshot(cat(data_home_sidebar_authors(pkg)))
})

test_that("role has multiple fallbacks", {
  skip_if_not_installed("rlang", "0.99")

  expect_equal(role_lookup("cre"), "maintainer")
  expect_equal(role_lookup("res"), "researcher")
  expect_snapshot(role_lookup("unknown"))
})
