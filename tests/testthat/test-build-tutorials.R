test_that("can autodetect published tutorials", {
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

test_that("meta overrides published", {
  jj_examples <- list(
    list(
      name = "00-setup",
      title = "Setting up R",
      url = "https://jjallaire.shinyapps.io/learnr-tutorial-00-setup/"
    ),
    list(
      name = "01-data-basics",
      title = "Data basics",
      url = "https://jjallaire.shinyapps.io/learnr-tutorial-01-data-basics/"
    )
  )

  out <- package_tutorials(
    test_path("assets/tutorials"),
    meta = list(tutorials = jj_examples)
  )
  expect_equal(nrow(out), 2)
  expect_equal(out$name, purrr::map_chr(jj_examples, "name"))
})
