context("topics")

topics <- tibble::tribble(
  ~name, ~ alias,
  "x",   c("a1", "a2"),
  "a",   c("a3"),
  "b1", "b1",
  "b2", "b2"
)

test_that("can select by any alias", {
  expect_equal(has_topic("a1", topics), c(TRUE, FALSE, FALSE, FALSE))
  expect_equal(has_topic("a2", topics), c(TRUE, FALSE, FALSE, FALSE))
})

test_that("can select by name", {
  expect_equal(has_topic("starts_with('x')", topics), c(TRUE, FALSE, FALSE, FALSE))
  expect_equal(has_topic("x", topics), c(TRUE, FALSE, FALSE, FALSE))
})

test_that("initial negative drops selected", {
  expect_equal(has_topic("-a1", topics), c(FALSE, TRUE, TRUE, TRUE))
})

test_that("can select then drop", {
  expect_equal(has_topic("starts_with('b')", topics), c(FALSE, FALSE, TRUE, TRUE))
  expect_equal(
    has_topic(c("starts_with('b')", "-b2"), topics),
    c(FALSE, FALSE, TRUE, FALSE)
  )
})
