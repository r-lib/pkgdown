test_that("parse failures include file name", {
  expect_snapshot(
    build_reference(test_path("assets/reference-fail"))
  )
})
