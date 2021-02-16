test_that("pkgdown_footer() works by default", {
  data <- list(
    package = list(authors = "bla"),
    pkgdown = list(version = "42")
  )
  pkg <- list()
  expect_snapshot(pkgdown_footer(data, pkg))
})

test_that("pkgdown_footer() can use custom components", {
  data <- list(
    package = list(authors = "bla"),
    pkgdown = list(version = "42")
  )
  pkg <- list(meta = list(footer = list(left = list(structure = c("authors", "pof")))))
  pkg$meta$footer$left$components$pof <- "***Wow***"
  expect_snapshot(pkgdown_footer(data, pkg))


  pkg <- list(meta = list(footer = list(left = list(structure = c("pof")))))
  pkg$meta$footer$left$components$pof <- "***Wow***"
  expect_snapshot(pkgdown_footer(data, pkg))
})

test_that("pkgdown_footer() throws informative error messages", {
  data <- list(
    authors = "bla",
    pkgdown = list(version = "42")
  )
  pkg <- list(meta = list(footer = list(left = list(structure = c("pof")))))
  expect_snapshot_error(pkgdown_footer(data, pkg))

  pkg <- list(meta = list(footer = list(right = list(structure = c("bof")))))
  expect_snapshot_error(pkgdown_footer(data, pkg))
})
