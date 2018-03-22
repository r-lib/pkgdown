context("test-init.R")

test_that("extra.css and extra.js copied and linked", {
  pkg <- test_path("init-extra-2")
  expect_output(init_site(pkg))
  on.exit(clean_site(pkg))

  expect_true(file_exists(path(pkg, "docs", "extra.css")))
  expect_true(file_exists(path(pkg, "docs", "extra.js")))

  # Now check they actually get used .
  expect_output(build_home(pkg))

  html <- xml2::read_html(path(pkg, "docs", "index.html"))
  links <- xml2::xml_find_all(html, ".//link")
  paths <- xml2::xml_attr(links, "href")

  expect_true("extra.css" %in% paths)
})

test_that("single extra.css correctly copied", {
  pkg <- test_path("init-extra-1")
  expect_output(init_site(pkg))
  on.exit(clean_site(pkg))

  expect_true(file_exists(path(pkg, "docs", "extra.css")))
})
