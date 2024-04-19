test_that("extra.css and extra.js copied and linked", {
  local_edition(3)
  pkg <- local_pkgdown_site(test_path("assets/init-extra-2"))
  suppressMessages(expect_message(init_site(pkg)))

  expect_true(file_exists(path(pkg$dst_path, "extra.css")))
  expect_true(file_exists(path(pkg$dst_path, "extra.js")))

  skip_if_no_pandoc()
  # Now check they actually get used .
  suppressMessages(expect_message(build_home(pkg)))

  html <- xml2::read_html(path(pkg$dst_path, "index.html"))
  paths <- xpath_attr(html, ".//link", "href")

  expect_true("extra.css" %in% paths)
})

test_that("single extra.css correctly copied", {
  local_edition(3)
  pkg <- local_pkgdown_site(test_path("assets/init-extra-1"))
  suppressMessages(expect_message(init_site(pkg)))

  expect_true(file_exists(path(pkg$dst_path, "extra.css")))
})

test_that("asset subdirectories are copied", {
  local_edition(3)
  pkg <- local_pkgdown_site(test_path("assets/init-asset-subdirs"))
  suppressMessages(expect_message(init_site(pkg)))

  expect_true(file_exists(path(pkg$dst_path, "subdir1", "file1.txt")))
  expect_true(file_exists(path(pkg$dst_path, "subdir1", "subdir2", "file2.txt")))
})

test_that("site meta doesn't break unexpectedly", {
  local_edition(3)
  pkgdown <- as_pkgdown(test_path("assets/reference"))

  # null out components that will vary
  yaml <- site_meta(pkgdown)
  yaml$pkgdown <- "{version}"
  yaml$pkgdown_sha <- "{sha}"
  yaml$pandoc <- "{version}"
  yaml$last_built <- timestamp(as.POSIXct("2020-01-01", tz = "UTC"))

  expect_snapshot(yaml)
})
