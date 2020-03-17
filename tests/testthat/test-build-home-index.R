context("test-build-home-index")


# repo_link ------------------------------------------------------------

test_that("package repo verification", {
  skip_on_cran() # requires internet connection

  expect_null(cran_link("notarealpkg"))

  expect_equal(
    cran_link("dplyr"),
    list(
      repo = "CRAN",
      url = "https://cloud.r-project.org/package=dplyr"
    )
  )

  expect_equal(
    cran_link("Biobase"),
    list(
      repo = "BIOC",
      url = "https://www.bioconductor.org/packages/Biobase"
    )
  )
})

test_that("homepage title defaults to package Title", {
  pkg <- test_path("assets/home-index-rmd")
  expect_equal(
    as.character(data_home(pkg))[[1]],
    "A test package"
  )
})

test_that("homepage title can be overridden", {
  pkg <- test_path("assets/home-index-rmd")
  pkg <- as_pkgdown(pkg)
  pkg$meta <- list(home = list(
    title = "Such a cool package"))

  expect_equal(
    as.character(data_home(pkg))[[1]],
    "Such a cool package"
  )

})

test_that("homepage description defaults to package Description", {
  pkg <- test_path("assets/home-index-rmd")
  expect_true(
    grepl("A test package",
    as.character(data_home(pkg))[[3]],
  )
  )
})

test_that("homepage description can be overridden", {
  pkg <- test_path("assets/home-index-rmd")
  pkg <- as_pkgdown(pkg)
  pkg$meta <- list(home = list(
    description = "A free description."))

  expect_true(
    grepl("A free description.",
          as.character(data_home(pkg))[[3]],
    )
  )

})

