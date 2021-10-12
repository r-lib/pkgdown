test_that("can autodetect tutorials", {
  # Can't embed in package because path is too long and gives R CMD check NOTE
  pkg <- test_path("assets/tutorials")
  dcf_src <- path(pkg, "vignettes/tutorials/test-1/")
  dcf_dst <- path(dcf_src, "rsconnect/documents/test-1.Rmd/shinyapps.io/hadley")
  dir_create(dcf_dst)
  file_copy(path(dcf_src, "tutorial-test-1.dcf"), dcf_dst, overwrite = TRUE)
  withr::defer(dir_delete(path(pkg, "vignettes/tutorials/test-1/rsconnect")))

  out <- package_tutorials(pkg)
  expect_equal(out$name, "test-1")
  expect_equal(out$file_out, "tutorials/test-1.html")
  expect_equal(out$url, "https://hadley.shinyapps.io/tutorial-test-1/")

  # and aren't included in vignettes
  out <- package_vignettes(test_path("assets/tutorials"))
  expect_equal(nrow(out), 0)
})

test_that("can manually supply tutorials", {
  meta <- list(
    tutorials = list(
      list(name = "1-name", title = "1-title", url = "1-url"),
      list(name = "2-name", title = "2-title", url = "2-url")
    )
  )

  out <- package_tutorials(test_path("assets/tutorials"), meta)
  expect_equal(out$name, c("1-name", "2-name"))
  expect_equal(out$file_out, c("tutorials/1-name.html", "tutorials/2-name.html"))
  expect_equal(out$url, c("1-url", "2-url"))
})
