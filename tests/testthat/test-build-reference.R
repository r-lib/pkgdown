test_that("parse failures include file name", {
  withr::defer(
    unlink(test_path("assets/reference-fail/docs"), recursive = TRUE)
  )

  expect_snapshot(error = TRUE,
    build_reference(test_path("assets/reference-fail"))
  )
})

test_that("dependencies are included in reference output", {
  withr::defer(
    unlink(test_path("assets/reference/docs"), recursive = TRUE)
  )

  build_reference(test_path("assets/reference"), topic = "e")
  lines <- read_lines(test_path("assets/reference/docs/reference/e.html"))
  expect_true(any(grepl("^<!-- dependencies from examples -->$", lines)))
  expect_true(any(grepl("<script src=\"libs/foo-1.0/foo.js\"></script>", lines)))
})
