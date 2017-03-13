context("build_home")

test_that("can build package without any index/readme", {
  expect_error(
    build_home(test_path("home-empty"), tempdir()),
    NA
  )
})

test_that("intermediate files cleaned up automatically", {
  pkg <- test_path("home-index-rmd")
  build_home(pkg, tempdir())

  expect_equal(dir(pkg), c("DESCRIPTION", "index.Rmd"))
})

test_that("link_license matchs exactly", {
  # Shouldn't match first GPL-2
  expect_equal(
    autolink_license("LGPL-2") ,
    "<a href='https://www.r-project.org/Licenses/LGPL-2'>LGPL-2</a>"
  )
})

test_that("link_license matches LICENSE", {
  expect_equal(
    autolink_license("LICENSE") ,
    "<a href='LICENSE'>LICENSE</a>"
  )
})
