test_that("adds github link when available", {
  verify_output(test_path("test-navbar/github.txt"), {
    pkg <- pkg_navbar()
    navbar_components(pkg)

    pkg <- pkg_navbar(github_url = "https://github.org/r-lib/pkgdown")
    navbar_components(pkg)
  })

  expect_equal(2 * 2, 4)
})
