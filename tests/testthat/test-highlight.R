test_that("pre() can produce needed range of outputs", {
  expect_snapshot({
    cat(pre("x"))
    cat(pre("x", r_code = TRUE))
    cat(pre("x", class = "test"))
    cat(pre("x", r_code = TRUE, class = "test"))
  })
})
