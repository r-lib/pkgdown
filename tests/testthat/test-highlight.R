test_that("highlight_examples captures depencies", {
  withr::defer(unlink("Rplot001.png"))

  dummy_dep <- htmltools::htmlDependency("dummy", "1.0.0", "dummy.js")
  widget <- htmlwidgets::createWidget("test", list(), dependencies = dummy_dep)
  out <- highlight_examples("widget", env = environment())

  # htmlwidgets always get dependency on htmlwidgets.js
  expect_equal(attr(out, "dependencies")[-1], list(dummy_dep))
})


test_that("pre() can produce needed range of outputs", {
  expect_snapshot({
    cat(pre("x"))
    cat(pre("x", r_code = TRUE))
  })
})
