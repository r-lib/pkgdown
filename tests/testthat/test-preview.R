local_preview_clean <- function(env = caller_env()) {
  the$server <- NULL
  withr::defer(the$server <- NULL, envir = env)
}

test_that("checks its inputs", {
  pkg <- local_pkgdown_site()

  expect_snapshot(error = TRUE, {
    preview_site(pkg, path = 1)
    preview_site(pkg, path = "foo")
    preview_site(pkg, preview = 1)
  })
})

test_that("local_path adds index.html if needed", {
  pkg <- local_pkgdown_site()
  file_create(path(pkg$dst_path, "test.html"))
  expect_equal(
    local_path(pkg, "test.html"),
    path(pkg$dst_path, "test.html")
  )

  dir_create(path(pkg$dst_path, "reference"))
  expect_equal(
    local_path(pkg, "reference"),
    path(pkg$dst_path, "reference")
  )
})

test_that("preview starts new server when none exists", {
  pkg <- local_pkgdown_site()
  local_preview_clean()
  urls <- character()
  withr::local_options(browser = function(url) urls <<- c(urls, url))

  preview_site(pkg, preview = TRUE)

  expect_false(is.null(the$server))
  expect_equal(the$server_root, pkg$dst_path)
  expect_length(urls, 1)
  expect_equal(urls[[1]], paste0(the$server$url, "/"))
})

test_that("preview reuses server for same root", {
  pkg <- local_pkgdown_site()
  local_preview_clean()
  urls <- character()
  withr::local_options(browser = function(url) urls <<- c(urls, url))

  preview_site(pkg, preview = TRUE)
  server1 <- the$server

  file_create(path(pkg$dst_path, "test.html"))
  preview_site(pkg, path = "test.html", preview = TRUE)

  expect_identical(the$server, server1)
  expect_length(urls, 2)
  expect_equal(urls[[2]], paste0(server1$url, "/test.html"))
})

test_that("preview starts new server for different root", {
  pkg1 <- local_pkgdown_site()
  pkg2 <- local_pkgdown_site()
  local_preview_clean()
  urls <- character()
  withr::local_options(browser = function(url) urls <<- c(urls, url))

  preview_site(pkg1, preview = TRUE)
  server1 <- the$server

  preview_site(pkg2, preview = TRUE)

  expect_false(identical(the$server, server1))
  expect_equal(the$server_root, pkg2$dst_path)
})

test_that("stop_preview stops server", {
  pkg <- local_pkgdown_site()
  local_preview_clean()
  withr::local_options(browser = function(url) {})

  preview_site(pkg, preview = TRUE)
  expect_false(is.null(the$server))

  stop_preview()
  expect_null(the$server)
  expect_null(the$server_root)
})

test_that("preview constructs correct URLs for sub-paths", {
  pkg <- local_pkgdown_site()
  local_preview_clean()
  urls <- character()
  withr::local_options(browser = function(url) urls <<- c(urls, url))

  dir_create(path(pkg$dst_path, "reference"))
  file_create(path(pkg$dst_path, "reference", "foo.html"))

  preview_site(pkg, preview = TRUE)
  base_url <- the$server$url

  preview_site(pkg, path = "reference", preview = TRUE)
  expect_equal(urls[[2]], paste0(base_url, "/reference"))

  preview_site(pkg, path = "reference/foo.html", preview = TRUE)
  expect_equal(urls[[3]], paste0(base_url, "/reference/foo.html"))
})
