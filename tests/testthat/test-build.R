test_that("both versions of build_site have same arguments", {
  expect_equal(formals(build_site_local), formals(build_site_external))
})

test_that("build_site can be made unquiet", {
  skip_if_no_pandoc()

  # `quiet = FALSE` from build_site() should get passed to
  # build_articles(), which will include some rmarkdown build out in the
  # messages, including "pandoc", which won't be there normally
  pkg <- local_pkgdown_site(test_path("assets/figure"))
  output_unquiet <- suppressMessages(
    capture.output(
      build_site(
        pkg,
        quiet = FALSE,
        preview = FALSE
      )
    )
  )
  expect_match(paste(output_unquiet, collapse = ""), "pandoc")

  output_quiet <- suppressMessages(
    capture.output(
      build_site(
        pkg,
        preview = FALSE
      )
    )
  )

  expect_no_match(paste(output_quiet, collapse = ""), "pandoc")
})
