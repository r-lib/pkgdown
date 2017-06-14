context("topics")

topics <- tibble::tribble(
  ~name, ~alias,        ~internal,  ~concepts,
  "x",   c("a1", "a2"), FALSE,      character(),
  "a",   c("a3"),       FALSE,      character(),
  "b1",  "b1",          FALSE,      "b",
  "b2",  "b2",          FALSE,      c("a", "b"),
  "i",   "i",           TRUE,       character()
)

test_that("can select by any alias", {
  expect_equal(select_topics("a1", topics), 1)
  expect_equal(select_topics("a2", topics), 1)
})

test_that("can select by name or topic that uses -", {
  bad_topics <- tibble::tribble(
    ~name, ~alias,        ~internal,  ~concepts,
    "a-b", "b-a",         FALSE,      character(),
    "ok",  c("a", "b"),   FALSE,      character()
  )

  expect_equal(select_topics("a-b", bad_topics), 1)
  expect_equal(select_topics("b-a", bad_topics), 1)
  expect_equal(select_topics("starts_with('a-')", bad_topics), 1)
  expect_equal(select_topics("starts_with('b-')", bad_topics), 1)
})

test_that("can select by name", {
  expect_equal(select_topics("starts_with('x')", topics), 1)
  expect_equal(select_topics("x", topics), 1)

})

test_that("preserves order", {
  expect_equal(select_topics(c("a", "b1", "x"), topics), c(2, 3, 1))
})

test_that("can select by concept", {
  expect_equal(select_topics("has_concept('b')", topics), c(3, 4))
})

test_that("initial negative drops selected", {
  expect_equal(select_topics("-a1", topics), 2:4)
})

test_that("can select then drop", {
  expect_equal(select_topics("starts_with('b')", topics), c(3, 4))
  expect_equal(select_topics(c("starts_with('b')", "-b2"), topics), 3)
})

test_that("internal selected by name or with internal = TRUE", {
  expect_equal(select_topics("i", topics), 5)
  expect_equal(select_topics("starts_with('i', internal = TRUE)", topics), 5)
})
