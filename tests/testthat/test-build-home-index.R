context("test-build-home-index")


# repo_link ------------------------------------------------------------

test_that("package repo verification", {
  skip_on_cran() # requires internet connection

  expect_null(repo_link("notarealpkg"))

  expect_equal(
    repo_link("dplyr"),
    list(
      repo = "CRAN",
      url = "https://cloud.r-project.org/package=dplyr"
    )
  )

  expect_equal(
    repo_link("Biobase"),
    list(
      repo = "BIOC",
      url = "https://www.bioconductor.org/packages/Biobase"
    )
  )
})

