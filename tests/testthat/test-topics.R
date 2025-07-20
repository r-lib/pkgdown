select_topics_ <- function(topic, topics, check = TRUE) {
  pkg <- local_pkgdown_site()
  select_topics(
    topic,
    topics,
    check = check,
    error_path = "reference[1].contents",
    error_pkg = pkg
  )
}

test_that("bad inputs give informative warnings", {
  # fmt: skip
  topics <- tibble::tribble(
    ~name, ~alias,        ~internal,  ~concepts,
    "x",   c("x", "x1"), FALSE,      character(),
  )

  expect_snapshot(error = TRUE, {
    select_topics_("x + ", topics)
    select_topics_("y", topics)
    select_topics_("paste(1)", topics)
    select_topics_("starts_with", topics)
    select_topics_("1", topics)

    select_topics_("starts_with('y')", topics)
  })
})

test_that("selector functions validate their inputs", {
  # fmt: skip
  topics <- tibble::tribble(
    ~name, ~alias,        ~internal,  ~concepts,
    "x",   c("x", "x1"), FALSE,      character(),
  )

  expect_snapshot(error = TRUE, {
    select_topics_("starts_with('x', 'y')", topics)
    select_topics_("starts_with(c('x', 'y'))", topics)
  })
})


test_that("empty input returns empty vector", {
  # fmt: skip
  topics <- tibble::tribble(
    ~name, ~alias,        ~internal,  ~concepts,
    "x",   c("x", "x1"), FALSE,      character(),
  )

  expect_equal(select_topics(character(), topics), integer())
})

test_that("can select by name or alias", {
  # fmt: skip
  topics <- tibble::tribble(
    ~name, ~alias,
    "x",   c("a1", "a2"),
    "a",   c("a3"),
    "a-b", "b-a",
    "c::d", "d",
  )

  expect_equal(select_topics_("x", topics), 1)
  expect_equal(select_topics_("'x'", topics), 1)
  expect_equal(select_topics_("a1", topics), 1)
  expect_equal(select_topics_("a2", topics), 1)
  expect_equal(select_topics_("c::d", topics), 4)

  # Even if name is non-syntactic
  expect_equal(select_topics_("a-b", topics), 3)
  expect_equal(select_topics_("b-a", topics), 3)

  # Or missing
  expect_snapshot(error = TRUE, {
    select_topics_("a4", topics)
    select_topics_("c::a", topics)
  })
})

test_that("selection preserves original order", {
  # fmt: skip
  topics <- tibble::tribble(
    ~name, ~alias,
    "x",   c("a1", "a2"),
    "a",   c("a3"),
    "b",   "b1"
  )

  expect_equal(select_topics_(c("a", "b1", "x"), topics), c(2, 3, 1))
})

test_that("can select by name", {
  # fmt: skip
  topics <- tibble::tribble(
    ~name, ~alias,   ~internal,
    "a",   "a",      FALSE,
    "b1",  "b1",     FALSE,
    "b2",  "b2",     FALSE,
    "b3",  "b3",     TRUE,
  )
  topics$alias <- as.list(topics$alias)

  expect_equal(select_topics_("starts_with('a')", topics), 1)
  expect_equal(select_topics_("ends_with('a')", topics), 1)
  expect_equal(select_topics_("contains('a')", topics), 1)
  expect_equal(select_topics_("matches('[a]')", topics), 1)

  # Match internal when requested
  expect_equal(select_topics_("starts_with('b')", topics), c(2, 3))
  expect_equal(select_topics_("starts_with('b', internal = TRUE)", topics), 2:4)
})

test_that("can select by presense or absence of concept", {
  # fmt: skip
  topics <- tibble::tribble(
    ~name, ~alias,        ~internal,  ~concepts,
    "b1",  "b1",          FALSE,      "a",
    "b2",  "b2",          FALSE,      c("a", "b"),
    "b3",  "b3",          FALSE,      character()
  )
  topics$alias <- as.list(topics$alias)

  expect_equal(select_topics_("has_concept('a')", topics), c(1, 2))
  expect_equal(select_topics_("lacks_concept('b')", topics), c(1, 3))
  expect_equal(select_topics_("lacks_concepts(c('a', 'b'))", topics), 3)
})

test_that("can select by keyword", {
  # fmt: skip
  topics <- tibble::tribble(
    ~name, ~alias,        ~internal,  ~keywords,
    "b1",  "b1",          FALSE,      "a",
    "b2",  "b2",          FALSE,      c("a", "b"),
  )
  topics$alias <- as.list(topics$alias)
  expect_equal(select_topics_("has_keyword('a')", topics), c(1, 2))
  expect_equal(select_topics_("has_keyword('b')", topics), c(2))
  expect_equal(
    select_topics_("has_keyword('c')", topics, check = FALSE),
    integer()
  )
})

test_that("can select by lifecycle", {
  # fmt: skip
  topics <- tibble::tribble(
    ~name, ~alias,        ~internal,  ~keywords, ~lifecycle,
    "b1",  "b1",          FALSE,      "a",         list("stable"),
    "b2",  "b2",          FALSE,      c("a", "b"), NULL
  )
  expect_equal(select_topics_("has_lifecycle('stable')", topics), 1)
  expect_equal(
    select_topics_("has_lifecycle('deprecated')", topics, check = FALSE),
    integer()
  )
})

test_that("can combine positive and negative selections", {
  # fmt: skip
  topics <- tibble::tribble(
    ~name, ~alias,        ~internal,
    "x",   c("a1", "a2"), FALSE,
    "a",   c("a3"),       FALSE,
    "b",   "b1",          FALSE,
    "d",   "d",           TRUE,
  )
  expect_equal(select_topics_("-x", topics), c(2, 3))
  expect_equal(select_topics_(c("-x", "-a"), topics), 3)
  expect_equal(select_topics_(c("-x", "x"), topics), c(2, 3, 1))
  expect_equal(select_topics_(c("a", "x", "-a"), topics), 1)

  expect_snapshot(select_topics_("c(a, -x)", topics), error = TRUE)
})

test_that("an unmatched selection generates a warning", {
  # fmt: skip
  topics <- tibble::tribble(
    ~name, ~alias,        ~internal,
    "x",   c("a1", "a2"), FALSE,
    "a",   c("a3"),       FALSE,
    "b",   "b1",          FALSE,
    "d",   "d",           TRUE,
  )

  expect_snapshot(
    error = TRUE,
    select_topics_(c("a", "starts_with('unmatched')"), topics),
  )
})

test_that("uses funs or aliases", {
  pkg <- local_pkgdown_site()
  # fmt: skip
  pkg$topics <- tibble::tribble(
    ~name, ~funs,         ~alias,        ~file_out, ~title, ~lifecycle,
    "x",   character(),   c("x1", "x2"), "x.html",  "X", NULL,
    "y",   c("y1", "y2"), "y3",          "y.html",  "Y", NULL
  )

  out <- section_topics(pkg, c("x", "y"), error_path = "reference[1].contents")
  expect_equal(out$aliases, list(c("x1", "x2"), c("y1", "y2")))
})

test_that("full topic selection process works", {
  pkg <- local_pkgdown_site(test_path("assets/reference"))

  # can mix local and remote
  out <- section_topics(
    pkg,
    c("a", "base::mean"),
    error_path = "reference[1].contents"
  )
  expect_equal(unname(out$name), c("a", "base::mean"))

  # concepts and keywords work
  out <- section_topics(
    pkg,
    c("has_concept('graphics')", "has_keyword('foo')"),
    error_path = "reference[1].contents"
  )
  expect_equal(unname(out$name), c("b", "a"))
})

test_that("an unmatched selection with a matched selection does not select everything", {
  # fmt: skip
  topics <- tibble::tribble(
    ~name, ~alias,        ~internal,
    "x",   c("a1", "a2"), FALSE,
    "a",   c("a3"),       FALSE,
    "b",   "b1",          FALSE,
    "d",   "d",           TRUE,
  )

  expect_equal(
    select_topics_(c("a", "starts_with('unmatched')"), topics, check = FALSE),
    2
  )

  expect_equal(
    select_topics_(c("starts_with('unmatched')", "a"), topics, check = FALSE),
    2
  )
})
