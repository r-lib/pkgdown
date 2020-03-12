context("test-topics.R")

test_that("bad inputs give informative warnings", {
  topics <- tibble::tribble(
    ~name, ~alias,        ~internal,  ~concepts,
    "x",   c("x", "x1"), FALSE,      character(),
  )

  verify_output(test_path("test-topics-warnings.txt"), {
    t <- select_topics("x + ", topics)
    t <- select_topics("y", topics)
    t <- select_topics("paste(1)", topics)
    t <- select_topics("starts_with", topics)
    t <- select_topics("1", topics)

    t <- select_topics("starts_with('y')", topics, check = TRUE)
  })
})

test_that("can select by name or alias", {
  topics <- tibble::tribble(
    ~name, ~alias,
    "x",   c("a1", "a2"),
    "a",   c("a3"),
    "a-b", "b-a"
  )

  expect_equal(select_topics("x", topics), 1)
  expect_equal(select_topics("'x'", topics), 1)
  expect_equal(select_topics("a1", topics), 1)
  expect_equal(select_topics("a2", topics), 1)

  # Even if name is non-syntactic
  expect_equal(select_topics("a-b", topics), 3)
  expect_equal(select_topics("b-a", topics), 3)

  # Or missing
  expect_warning(select_topics("a4", topics), "known topic")
})

test_that("selection preserves original order", {
  topics <- tibble::tribble(
    ~name, ~alias,
    "x",   c("a1", "a2"),
    "a",   c("a3"),
    "b",   "b1"
  )

  expect_equal(select_topics(c("a", "b1", "x"), topics), c(2, 3, 1))
})

test_that("can select by name", {
  topics <- tibble::tribble(
    ~name, ~alias,   ~internal,
    "a",   "a",      FALSE,
    "b1",  "b1",     FALSE,
    "b2",  "b2",     FALSE,
    "b3",  "b3",     TRUE,
  )
  topics$alias <- as.list(topics$alias)

  expect_equal(select_topics("starts_with('a')", topics), 1)
  expect_equal(select_topics("ends_with('a')", topics), 1)
  expect_equal(select_topics("contains('a')", topics), 1)
  expect_equal(select_topics("matches('[a]')", topics), 1)

  # Match internal when requested
  expect_equal(select_topics("starts_with('b')", topics), c(2, 3))
  expect_equal(select_topics("starts_with('b', internal = TRUE)", topics), 2:4)
})

test_that("can select by presense or absence of concept", {
  topics <- tibble::tribble(
    ~name, ~alias,        ~internal,  ~concepts,
    "b1",  "b1",          FALSE,      "a",
    "b2",  "b2",          FALSE,      c("a", "b"),
    "b3",  "b3",          FALSE,      character()
  )
  topics$alias <- as.list(topics$alias)

  expect_equal(select_topics("has_concept('a')", topics), c(1, 2))
  expect_equal(select_topics("lacks_concepts('b')", topics), c(1, 3))
  expect_equal(select_topics("lacks_concepts(c('a', 'b'))", topics), 3)
})

test_that("can select by keyword", {
  topics <- tibble::tribble(
    ~name, ~alias,        ~internal,  ~keywords,
    "b1",  "b1",          FALSE,      "a",
    "b2",  "b2",          FALSE,      c("a", "b"),
  )
  topics$alias <- as.list(topics$alias)
  expect_equal(select_topics("has_keyword('a')", topics), c(1, 2))
  expect_equal(select_topics("has_keyword('b')", topics), c(2))
  expect_equal(select_topics("has_keyword('c')", topics), integer())
})

test_that("can combine positive and negative selections", {
  topics <- tibble::tribble(
    ~name, ~alias,        ~internal,
    "x",   c("a1", "a2"), FALSE,
    "a",   c("a3"),       FALSE,
    "b",   "b1",          FALSE,
    "d",   "d",           TRUE,
  )

  expect_equal(select_topics("-x", topics), c(2, 3))
  expect_equal(select_topics(c("-x", "-a"), topics), 3)
  expect_equal(select_topics(c("-x", "x"), topics), c(2, 3, 1))
  expect_equal(select_topics(c("a", "x", "-a"), topics), 1)

  expect_error(select_topics("c(a, -x)", topics), "all negative or all positive")
})

test_that("an unmatched selection generates a warning", {
  topics <- tibble::tribble(
    ~name, ~alias,        ~internal,
    "x",   c("a1", "a2"), FALSE,
    "a",   c("a3"),       FALSE,
    "b",   "b1",          FALSE,
    "d",   "d",           TRUE,
  )

  expect_warning(
    select_topics(c("a", "starts_with('unmatched')"), topics, check = TRUE),
    "topic must match a function or concept"
  )
})
