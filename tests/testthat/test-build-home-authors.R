context("test-build-home-authors")

# orcid ------------------------------------------------------------------

test_that("ORCID can be identified from all comment styles", {
  pkg <- as_pkgdown(test_path("assets/site-orcid"))
  author_info <- data_author_info(pkg)
  authors <- pkg %>%
    pkg_authors() %>%
    purrr::map(author_list, author_info)
  expect_length(authors, 5)
})

test_that("names can be removed from persons", {
  p0 <- person("H", "W")
  p1 <- person("H", "W", role = "ctb", comment = "one")
  p2 <- person("H", "W", comment = c("one", "two"))
  p3 <- person("H", "W", comment = c("one", ORCID = "orcid"))
  p4 <- person("H", "W", comment = c(ORCID = "orcid"))
  p5 <- person("H", "W", comment = c(ORCID = "orcid1", ORCID = "orcid2"))

  expect_null(remove_name(p0$comment, "ORCID"))
  expect_equal(remove_name(p1$comment, "ORCID"), "one")
  expect_equal(remove_name(p2$comment, "ORCID"), c("one", "two"))
  expect_length(remove_name(p3$comment, "ORCID"), 1)
  expect_length(remove_name(p4$comment, "ORCID"), 0)
  expect_length(remove_name(p5$comment, "ORCID"), 0)
})

test_that("Comments in authors info are linkified", {
  p <- list(name = "Jane Doe", roles = "rev", comment = "<https://x.org/>")

  expect_match(
    author_desc(p),
    "&lt;<a href='https://x.org/'>https://x.org/</a>&gt;)</small>"
  )
})
