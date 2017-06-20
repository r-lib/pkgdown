context("highlight")

test_that("can link to external packages", {
  # Functions
  expect_equal(
    highlight_text("MASS::addterm()"),
    "<span class='kw pkg'>MASS</span><span class='kw ns'>::</span><span class='fu'><a href='http://www.rdocumentation.org/packages/MASS/topics/addterm'>addterm</a></span>()"
  )

  # And bare symbols
  expect_equal(
    highlight_text("MASS::addterm"),
    "<span class='kw pkg'>MASS</span><span class='kw ns'>::</span><span class='no'><a href='http://www.rdocumentation.org/packages/MASS/topics/addterm'>addterm</a></span>"
  )
})
