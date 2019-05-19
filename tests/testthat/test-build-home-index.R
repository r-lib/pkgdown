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

test_that("page title defaults to package title", {
  pkg <- test_path("assets/home-index-rmd")
  expect_equal(
    as.character(data_home(pkg))[[1]],
    "A test package"
  )
})

test_that("page title can be overridden", {
  pkg <- test_path("assets/home-index-rmd")
  pkg <- as_pkgdown(pkg)
  pkg$meta <- list(home = list(
    title = "Such a cool package"))

  expect_equal(
    as.character(data_home(pkg))[[1]],
    "Such a cool package"
  )

})
