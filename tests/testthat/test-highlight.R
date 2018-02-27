context("highlight")

test_that("can link to external topics that use ::", {
  scoped_package_context("test")

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


test_that("can link to implicit remote topics with library()", {
  scoped_package_context("test", c("foo" = "bar"))
  scoped_file_context()
  register_attached_packages("MASS")

  expect_equal(
    highlight_text("addterm()"),
    "<span class='fu'><a href='http://www.rdocumentation.org/packages/MASS/topics/addterm'>addterm</a></span>()"
  )
})
