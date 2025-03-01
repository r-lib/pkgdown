test_that("can autodetect tutorials", {
  pkg <- local_pkgdown_site()
  base_path <- "vignettes/tutorials/test-1"
  pkg <- pkg_add_file(
    pkg,
    path(base_path, "test-1.Rmd"),
    c(
      '---',
      'title: "Tutorial"',
      'output: learnr::tutorial',
      'runtime: shiny_prerendered',
      '---'
    )
  )
  path <- path(
    base_path,
    "rsconnect/documents/test-1.Rmd/shinyapps.io/hadley/tutorial-test-1.dcf"
  )
  pkg <- pkg_add_file(
    pkg,
    path,
    c(
      "name: tutorial-test-1",
      "title: tutorial-test-1",
      "hostUrl: https://api.shinyapps.io/v1",
      "when: 1521734722.72611",
      "url: https://hadley.shinyapps.io/tutorial-test-1/"
    )
  )

  out <- package_tutorials(pkg$src_path)
  expect_equal(out$name, "test-1")
  expect_equal(out$file_out, "tutorials/test-1.html")
  expect_equal(out$url, "https://hadley.shinyapps.io/tutorial-test-1/")

  # and aren't included in vignettes
  out <- package_vignettes(pkg$src_path)
  expect_equal(nrow(out), 0)
})

test_that("can manually supply tutorials", {
  meta <- list(
    tutorials = list(
      list(name = "1-name", title = "1-title", url = "1-url"),
      list(name = "2-name", title = "2-title", url = "2-url")
    )
  )

  pkg <- local_pkgdown_site()
  out <- package_tutorials(pkg, meta)
  expect_equal(out$name, c("1-name", "2-name"))
  expect_equal(
    out$file_out,
    c("tutorials/1-name.html", "tutorials/2-name.html")
  )
  expect_equal(out$url, c("1-url", "2-url"))
})
