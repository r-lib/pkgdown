test_that("multiplication works", {
  expect_output(expect_error(
    build_reference(test_path("assets/reference-fail")),
    "f.Rd"
  ))
})
