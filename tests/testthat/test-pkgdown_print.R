test_that("widgets and browseable html are kept as is", {
  widget <- htmlwidgets::createWidget("test", list())
  expect_s3_class(pkgdown_print(widget), "htmlwidget")

  html <- htmltools::browsable(htmltools::div("foo"))
  expect_s3_class(pkgdown_print(html), "shiny.tag")
})

test_that("htmlwidgets get sized", {
  local_context_eval(list(fig.width = 7, dpi = 100, fig.asp = 1))

  widget <- htmlwidgets::createWidget("test", list())
  value <- pkgdown_print(widget)

  expect_equal(value$width, 700)
  expect_equal(value$height, 700)
})

test_that("respect htmlwidgets width", {
  local_context_eval(list(fig.width = 7, dpi = 100, fig.asp = 1))

  widget <- htmlwidgets::createWidget("test", list(), width = "100px")
  value <- pkgdown_print(widget)

  expect_equal(value$width, "100px")
})
