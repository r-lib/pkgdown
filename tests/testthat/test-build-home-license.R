test_that("link_license matchs exactly", {
  # Shouldn't match first GPL-2
  expect_equal(
    autolink_license("LGPL-2"),
    "<a href='https://www.r-project.org/Licenses/LGPL-2'>LGPL-2</a>"
  )

  expect_equal(
    autolink_license("MPL-2.0"),
    "<a href='https://www.mozilla.org/en-US/MPL/2.0/'>MPL-2.0</a>"
  )
})

test_that("link_license matches LICENSE", {
  expect_equal(
    autolink_license("LICENSE"),
    "<a href='LICENSE-text.html'>LICENSE</a>"
  )
  expect_equal(
    autolink_license("LICENCE"),
    "<a href='LICENSE-text.html'>LICENCE</a>"
  )
})
