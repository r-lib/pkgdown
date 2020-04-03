context("test-highlight.R")

test_that("can link to external topics that use ::", {
  scoped_package_context("test", c(foo = "bar"))
  scoped_file_context("test")

  # Functions
  expect_equal(
    highlight_text("MASS::addterm()"),
    "<span class='kw pkg'>MASS</span><span class='kw ns'>::</span><span class='fu'><a href='https://rdrr.io/pkg/MASS/man/addterm.html'>addterm</a></span>()"
  )

  # And bare symbols
  expect_equal(
    highlight_text("MASS::addterm"),
    "<span class='kw pkg'>MASS</span><span class='kw ns'>::</span><span class='no'><a href='https://rdrr.io/pkg/MASS/man/addterm.html'>addterm</a></span>"
  )

  # Local package gets local link
  expect_equal(
    highlight_text("test::foo()"),
    "<span class='kw pkg'>test</span><span class='kw ns'>::</span><span class='fu'><a href='bar.html'>foo</a></span>()"
  )
})

test_that("can link to implicit remote topics with library()", {
  scoped_package_context("test")
  scoped_file_context()
  register_attached_packages("MASS")

  expect_equal(
    highlight_text("addterm()"),
    "<span class='fu'><a href='https://rdrr.io/pkg/MASS/man/addterm.html'>addterm</a></span>()"
  )
})

test_that("can link to implicit base topics", {
  scoped_package_context("test")
  scoped_file_context()

  expect_equal(
    highlight_text("median()"),
    "<span class='fu'><a href='https://rdrr.io/r/stats/median.html'>median</a></span>()"
  )
})

test_that("can parse code with carriage returns", {
  scoped_package_context("test")

  expect_equal(
    highlight_text("1\r\n2"),
    "<span class='fl'>1</span>\n<span class='fl'>2</span>"
  )
})

test_that("unparsed code is still escaped", {
  scoped_package_context("test")

  expect_equal(highlight_text("<"), "&lt;")
})
