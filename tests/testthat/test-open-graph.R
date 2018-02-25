context("Open Graph meta tags")

out <- fs::file_temp()
teardown(fs::dir_delete(out))

test_that("open-graph test site is successfully built", {
  pkg <- test_path("open-graph")
  expect_output(build_site(pkg, out))
})

test_that("og tags are populated on index.html", {
  index_html <- readLines(file.path(out, "index.html"))
  desc <- '<meta property="og:description" content="A longer statement about the package.">'
  expect_true(desc %in% index_html)
  img <- '<meta property="og:image" content="http://example.com/pkg/logo.png">'
  expect_true(img %in% index_html)
})

test_that("og tags are populated on reference pages", {
  pork_html <- readLines(file.path(out, "reference", "pulledpork.html"))
  desc <- '<meta property="og:description" content="Pulled pork is delicious" />'
  expect_true(desc %in% pork_html)
  img <- '<meta property="og:image" content="http://example.com/pkg/logo.png" />'
  expect_true(img %in% pork_html)
})

test_that("og tags are populated on vignettes", {
  vignette_html <- readLines(file.path(out, "articles", "open-graph.html"))
  desc <- '<meta property="og:description" content="The Open Graph protocol is a standard for web page metadata.">'
  expect_true(desc %in% vignette_html)
  img <- '<meta property="og:image" content="http://example.com/pkg/logo.png">'
  expect_true(img %in% vignette_html)
})

test_that("if there is no logo.png, there is no og:image tag", {
  nologo <- fs::file_temp()
  expect_output(build_site(test_path("home-readme-rmd"), nologo))
  index_html <- readLines(file.path(nologo, "index.html"))
  expect_false(any(grepl("og:image", index_html, fixed = TRUE)))
})
