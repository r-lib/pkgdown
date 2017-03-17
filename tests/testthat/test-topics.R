context("topics")

topics <- tibble::tribble(
  ~name, ~alias,        ~internal,
  "x",   c("a1", "a2"), FALSE,
  "a",   c("a3"),       FALSE,
  "b1", "b1",           FALSE,
  "b2", "b2",           FALSE,
  "i",  "i",            TRUE
)

test_that("can select by any alias", {
  expect_equal(has_topic("a1", topics), c(TRUE, FALSE, FALSE, FALSE, FALSE))
  expect_equal(has_topic("a2", topics), c(TRUE, FALSE, FALSE, FALSE, FALSE))
})

test_that("can select by name", {
  expect_equal(has_topic("starts_with('x')", topics), c(TRUE, FALSE, FALSE, FALSE, FALSE))
  expect_equal(has_topic("x", topics), c(TRUE, FALSE, FALSE, FALSE, FALSE))
})

test_that("initial negative drops selected", {
  expect_equal(has_topic("-a1", topics), c(FALSE, TRUE, TRUE, TRUE, FALSE))
})

test_that("can select then drop", {
  expect_equal(
    has_topic("starts_with('b')", topics),
    c(FALSE, FALSE, TRUE, TRUE, FALSE)
  )
  expect_equal(
    has_topic(c("starts_with('b')", "-b2"), topics),
    c(FALSE, FALSE, TRUE, FALSE, FALSE)
  )
})

test_that("internal selected by name or with internal = TRUE", {
  expect_equal(has_topic("i", topics), c(FALSE, FALSE, FALSE, FALSE, TRUE))
  expect_equal(
    has_topic("starts_with('i', internal = TRUE)", topics),
    c(FALSE, FALSE, FALSE, FALSE, TRUE)
  )

})
