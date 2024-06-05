test_that("sitrep complains about BS3", {
  pkg <- local_pkgdown_site(
    meta = list(
      template = list(bootstrap = 3),
      url = "https://example.com"
    ),
    desc = list(URL = "https://example.com")
  )
  expect_snapshot(pkgdown_sitrep(pkg))
})

test_that("sitrep reports all problems", {
  pkg <- local_pkgdown_site(
    test_path("assets/reference"),
    list(reference = list(
      list(title = "Title", contents = c("a", "b", "c", "e"))
    ))
  )
  
  expect_snapshot(pkgdown_sitrep(pkg))
})

test_that("checks fails on first problem", {
  pkg <- local_pkgdown_site(
    test_path("assets/reference"),
    list(reference = list(
      list(title = "Title", contents = c("a", "b", "c", "e"))
    ))
  )
  
  expect_snapshot(check_pkgdown(pkg), error = TRUE)
})

test_that("both inform if everything is ok", {
  pkg <- local_pkgdown_site(
    meta = list(url = "https://example.com"),
    desc = list(URL = "https://example.com")
  )

  expect_snapshot({
    pkgdown_sitrep(pkg)
    check_pkgdown(pkg)
  })
})

# check urls ------------------------------------------------------------------

test_that("check_urls reports problems", {
  # URL not in the pkgdown config
  pkg <- local_pkgdown_site()
  expect_snapshot(check_urls(pkg), error = TRUE)

  # URL only in the pkgdown config
  pkg <- local_pkgdown_site(meta = list(url = "https://testpackage.r-lib.org"))
  expect_snapshot(check_urls(pkg), error = TRUE)
})

# check favicons --------------------------------------------------------------

test_that("check_favicons reports problems", {
  pkg <- local_pkgdown_site()

  # no logo no problems
  expect_no_error(check_favicons(pkg))

  # logo but no favicons
  file_touch(path(pkg$src_path, "logo.svg"))
  expect_snapshot(check_favicons(pkg), error = TRUE)
  
  # logo and old favicons
  dir_create(path_favicons(pkg))
  file_touch(path(path_favicons(pkg), "favicon.ico"), Sys.time() - 86400)
  expect_snapshot(check_favicons(pkg), error = TRUE)

  # logo and new favicons
  file_touch(path(path_favicons(pkg), "favicon.ico"), Sys.time() + 86400)
  expect_no_error(check_favicons(pkg))
})
