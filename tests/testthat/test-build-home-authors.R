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
  expect_equal(data_authors_page(pkg)$before, "Dream team:")
  expect_equal(data_authors_page(pkg)$after, "You are welcome!")
})

test_that("data_home_sidebar_authors() works with text", {
  pkg <- as_pkgdown(test_path("assets/sidebar-comment"))
  pkg$meta$authors$sidebar$before <- "yay"
  pkg$meta$authors$sidebar$after <- "cool"
  expect_snapshot(cat(data_home_sidebar_authors(pkg)))
})
