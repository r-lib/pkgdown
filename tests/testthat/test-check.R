test_that("fails if reference index incomplete", {
  pkg <- local_pkgdown_site(test_path("assets/reference"), meta = "
    reference:
     - title: Title
       contents: [a, b, c, e]
  ")
  expect_snapshot(check_pkgdown(pkg), error = TRUE)
})


test_that("fails if article index incomplete", {
  pkg <- local_pkgdown_site(test_path("assets/articles"), meta = "
    articles:
     - title: Title
       contents: [starts_with('html'), random, standard, toc-false, widget, needs-escape]
  ")
  expect_snapshot(check_pkgdown(pkg), error = TRUE)
})

test_that("informs if everything is ok", {
  pkg <- local_pkgdown_site(test_path("assets/reference"))
  expect_snapshot(check_pkgdown(pkg))
})

# built site ---------------------------------------------------------------

test_that("warn about missing images in readme", {
  pkg <- local_pkgdown_site(test_path("assets/bad-images"))
  suppressMessages(build_home(pkg))

  expect_snapshot(check_built_site(pkg))
})

test_that("readme can use images from vignettes", {
  pkg <- local_pkgdown_site(test_path("assets/bad-images"))
  file_copy(
    test_path("assets/articles-images/man/figures/kitten.jpg"),
    path(pkg$src_path, "vignettes/kitten.jpg")
  )
  withr::defer(unlink(path(pkg$src_path, "vignettes/kitten.jpg")))

  suppressMessages(build_home(pkg))
  suppressMessages(build_articles(pkg))

  suppressMessages(expect_no_warning(check_built_site(pkg)))
})
