context("test-tutorials.R")

jj_examples <- list(
  list(
    name =   "00-setup",
    title =  "Setting up R",
    url =    "https://jjallaire.shinyapps.io/learnr-tutorial-00-setup/"
  ),
  list(
    name =   "01-data-basics",
    title =  "Data basics",
    url =    "https://jjallaire.shinyapps.io/learnr-tutorial-01-data-basics/"
  )
)

test_that("can autodetect published tutorials", {
  skip_if_not_installed("rsconnect")
  skip_if(is.null(rsconnect::accounts()))

  # Can't embed in package because path is too long and gives R CMD check NOTE
  pkg <- test_path("tutorials-inst")
  dcf_src <- path(pkg, "inst/tutorials/test-1/tutorial-test-1.dcf")
  dcf_dst <- path(pkg, "inst/tutorials/test-1/rsconnect/documents/test-1.Rmd/shinyapps.io/hadley/tutorial-test-1.dcf")
  dir_create(path_dir(dcf_dst))
  file_copy(dcf_src, dcf_dst)
  on.exit(file_delete(dcf_dst), add = TRUE)
  on.exit(dir_delete(path_dir(dcf_dst)), add = TRUE)

  out <- package_tutorials(pkg)
  expect_equal(nrow(out), 1)
  expect_equal(out$name, "test-1")
})

test_that("meta overrides published", {
  out <- package_tutorials(
    test_path("tutorials-inst"),
    meta = list(tutorials = jj_examples)
  )
  expect_equal(nrow(out), 2)
  expect_equal(out$name, purrr::map_chr(jj_examples, "name"))
})

test_that("tutorials not included in articles", {
  out <- package_vignettes(test_path("tutorials-vignettes"))
  expect_equal(nrow(out), 0)
})
