context("replay")


# Output labelling --------------------------------------------------------

test_that("prompt added to start of each line", {
  expect_equal(label_lines("a\nb\n\n", prompt = "#"), c("#a", "#b", "#"))
})

test_that("prompt is escaped", {
  expect_equal(label_lines("\n", prompt = ">"), "&gt;")
})

test_that("input is escaped", {
  expect_equal(label_lines(">", prompt = ""), "&gt;")
})

test_that("class generates line-by-line span", {
  expect_equal(
    label_lines("a\nb", "X", prompt = ""),
    c("<span class='X'>a</span>", "<span class='X'>b</span>")
  )
})
