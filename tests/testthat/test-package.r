context("package")

test_that("as.sd_package creates a valid object", {
  pkg <- as.sd_package("../..")

  # is normal devtools package:
  expect_identical(pkg$package, "staticdocs")

  # has additional stuff:
  expect_identical(c("index", "icons", "mathjax", "rd", "rd_index") %in% names(pkg), rep(TRUE, 5L))
})

test_that("as.sd_package attaches Rds", {
  pkg <- as.sd_package("../..")

  n_topics <- nrow(pkg$rd_index)
  expect_gte(n_topics, 1L)
  expect_length(pkg$rd, n_topics)

  rd_classes <- vapply(pkg$rd, class, character(1L), USE.NAMES = FALSE)
  expect_identical(rd_classes, rep("Rd", n_topics))
})
