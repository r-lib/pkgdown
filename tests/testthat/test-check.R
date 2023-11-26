cli::test_that_cli("fails if reference index incomplete", {
  pkg <- local_pkgdown_site(test_path("assets/reference"), meta = "
    reference:
     - title: Title
       contents: [a, b, c, e]
  ")
  expect_snapshot(check_pkgdown(pkg), error = TRUE)
})


cli::test_that_cli("fails if article index incomplete", {
  pkg <- local_pkgdown_site(test_path("assets/articles"), meta = "
    articles:
     - title: Title
       contents: [starts_with('html'), standard, toc-false, widget]
  ")
  expect_snapshot(check_pkgdown(pkg), error = TRUE)
})

cli::test_that_cli("informs if everything is ok", {
  pkg <- local_pkgdown_site(test_path("assets/reference"))
  expect_snapshot(check_pkgdown(pkg))
})
