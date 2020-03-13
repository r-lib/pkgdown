test_that("adds github link when available", {
  verify_output(test_path("test-navbar/github.txt"), {
    pkg <- pkg_navbar()
    navbar_components(pkg)

    pkg <- pkg_navbar(github_url = "https://github.org/r-lib/pkgdown")
    navbar_components(pkg)
  })
})

test_that("vignette with package name turns into getting started", {
  verify_output(test_path("test-navbar/getting-started.txt"), {
    vig <- pkg_navbar_vignettes("test", "Testing", "test.html")
    pkg <- pkg_navbar(vignettes = vig)
    navbar_components(pkg)
  })
})
