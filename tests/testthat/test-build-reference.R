test_that("parse failures include file name", {
  withr::defer(
    unlink(test_path("assets/reference-fail/docs"), recursive = TRUE)
  )

  expect_snapshot(error = TRUE,
    build_reference(test_path("assets/reference-fail"))
  )
})


test_that("examples_env runs pre and post code", {
  dst_path <- withr::local_tempdir()
  dir_create(path(dst_path, "reference"))

  pkg <- list(
    package = "test",
    src_path = test_path("assets/reference-pre-post"),
    dst_path = dst_path
  )

  env <- local(examples_env(pkg))
  expect_equal(env$a, 2)
})
