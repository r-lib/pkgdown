test_that("parse failures include file name", {
  withr::defer(
    unlink(test_path("assets/reference-fail/docs"), recursive = TRUE)
  )

  expect_snapshot(
    build_reference(test_path("assets/reference-fail"))
  )
})
