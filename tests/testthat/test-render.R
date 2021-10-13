test_that("check_bootswatch_theme() works", {
  expect_snapshot_error(check_bootswatch_theme("paper", 4, list()))
  expect_null(check_bootswatch_theme(NULL, 4, list()))
  expect_null(check_bootswatch_theme("lux", 4, list()))
})

test_that("get_bs_version gives an informative error message", {
  pkg <- test_path("assets/sidebar")
  pkg <- as_pkgdown(pkg)
  pkg$meta$template$bootstrap <- 5
  expect_snapshot_error(get_bs_version(pkg))
})

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
  pkg <- test_path("assets/sidebar")
  pkg <- as_pkgdown(pkg)
  pkg$meta$footer$left$structure <- c("pof")
  expect_snapshot_error(pkgdown_footer(data, pkg))

  pkg <- test_path("assets/sidebar")
  pkg <- as_pkgdown(pkg)
  pkg$meta$footer$left$structure <- c("pkgdown")
  pkg$meta$footer$right$structure <- c("bof")
  expect_snapshot_error(pkgdown_footer(data, pkg))
})
