context("test-init.R")

test_that("extra.css and extra.js copied and linked", {
  pkg <- test_path("assets/init-extra-2")
  expect_output(init_site(pkg))
  on.exit(clean_site(pkg))

  expect_true(file_exists(path(pkg, "docs", "extra.css")))
  expect_true(file_exists(path(pkg, "docs", "extra.js")))

  skip_if_no_pandoc()
  # Now check they actually get used .
  expect_output(build_home(pkg))

  html <- xml2::read_html(path(pkg, "docs", "index.html"))
  links <- xml2::xml_find_all(html, ".//link")
  paths <- xml2::xml_attr(links, "href")

  expect_true("extra.css" %in% paths)
})

test_that("single extra.css correctly copied", {
  pkg <- test_path("assets/init-extra-1")
  expect_output(init_site(pkg))
  on.exit(clean_site(pkg))

  expect_true(file_exists(path(pkg, "docs", "extra.css")))
})

test_that("asset subdirectories are copied", {
  pkg <- test_path("assets/init-asset-subdirs")
  expect_output(init_site(pkg))
  on.exit(clean_site(pkg))

  expect_true(file_exists(path(pkg, "docs", "subdir1", "file1.txt")))
  expect_true(file_exists(path(pkg, "docs", "subdir1", "subdir2", "file2.txt")))
})

test_that("site meta doesn't break unexpectedly", {
  # Because paths are different during R CMD check
  skip_if_not(file_exists("../../DESCRIPTION"))
  pkgdown <- as_pkgdown(test_path("../.."))

  # null out components that will vary
  yaml <- site_meta(pkgdown)
  yaml$pkgdown <- "{version}"
  yaml$pkgdown_sha <- "{sha}"
  yaml$pandoc <- "{version}"
  yaml$last_built <- timestamp(as.POSIXct("2020-01-01"))

  # TODO: use snapshot test
  verify_output(test_path("test-init-meta.txt"), yaml)
})
