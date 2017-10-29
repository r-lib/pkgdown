context("Open Graph meta tags")

test_that("og tags are populated", {
  pkg <- test_path("open-graph")
  out <- tempdir()
  build_site(pkg, out)
  desc <- '<meta property="og:description" content="A longer statement about the package.">'
  expect_true(desc %in% readLines(file.path(out, "index.html")))
})
