context("Open Graph meta tags")

# This is hacky and needs to be cleaned up
pkg <- as_pkgdown(test_path("open-graph"))
setup(expect_output(build_site(pkg)))
teardown(clean_site(pkg))

test_that("og tags are populated on index.html", {
  index_html <- read_lines(path(pkg$dst_path, "index.html"))
  desc <- '<meta property="og:description" content="A longer statement about the package.">'
  expect_true(desc %in% index_html)
  img <- '<meta property="og:image" content="http://example.com/pkg/logo.png">'
  expect_true(img %in% index_html)
})

test_that("og tags are populated on reference pages", {
  pork_html <- read_lines(path(pkg$dst_path, "reference", "pulledpork.html"))
  desc <- '<meta property="og:description" content="Pulled pork is delicious" />'
  expect_true(desc %in% pork_html)
  img <- '<meta property="og:image" content="http://example.com/pkg/logo.png" />'
  expect_true(img %in% pork_html)
})

test_that("og tags are populated on vignettes", {
  vignette_html <- read_lines(path(pkg$dst_path, "articles", "open-graph.html"))
  desc <- '<meta property="og:description" content="The Open Graph protocol is a standard for web page metadata.">'
  expect_true(desc %in% vignette_html)
  img <- '<meta property="og:image" content="http://example.com/pkg/logo.png">'
  expect_true(img %in% vignette_html)
})

test_that("if there is no logo.png, there is no og:image tag", {
  pkg <- as_pkgdown(test_path("home-readme-rmd"))
  expect_output(build_site(pkg))
  on.exit(clean_site(pkg))

  index_html <- read_lines(path(pkg$dst_path, "index.html"))
  expect_false(any(grepl("og:image", index_html, fixed = TRUE)))
})
