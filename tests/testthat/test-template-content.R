context("test-template-content")

# Open Graph ------------------------------------------

test_that("og tags are populated on home, reference, and articles", {
  skip_if_no_pandoc()

  pkg <- as_pkgdown(test_path("assets/open-graph"))
  setup(expect_output(build_site(pkg, new_process = FALSE)))
  on.exit(clean_site(pkg))
  on.exit(dir_delete(path(pkg$src_path, "pkgdown")))

  index_html <- read_lines(path(pkg$dst_path, "index.html"))
  desc <- '<meta property="og:description" content="A longer statement about the package.">'
  expect_true(desc %in% index_html)
  img <- '<meta property="og:image" content="http://example.com/pkg/logo.png">'
  expect_true(img %in% index_html)

  pork_html <- read_lines(path(pkg$dst_path, "reference", "f.html"))
  desc <- '<meta property="og:description" content="Title" />'
  expect_true(desc %in% pork_html)
  img <- '<meta property="og:image" content="http://example.com/pkg/logo.png" />'
  expect_true(img %in% pork_html)

  vignette_html <- read_lines(path(pkg$dst_path, "articles", "open-graph.html"))
  desc <- '<meta property="og:description" content="The Open Graph protocol is a standard for web page metadata.">'
  expect_true(desc %in% vignette_html)
  img <- '<meta property="og:image" content="http://example.com/pkg/logo.png">'
  expect_true(img %in% vignette_html)
})

test_that("if there is no logo.png, there is no og:image tag", {
  skip_if_no_pandoc()

  pkg <- as_pkgdown(test_path("assets/home-readme-rmd"))
  expect_output(build_site(pkg, new_process = FALSE))
  on.exit(clean_site(pkg))

  index_html <- read_lines(path(pkg$dst_path, "index.html"))
  expect_false(any(grepl("og:image", index_html, fixed = TRUE)))
})
