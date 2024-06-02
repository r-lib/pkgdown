test_that("can generate three types of row", {
  ref <- list(
    list(title = "A"),
    list(subtitle = "B"),
    list(contents = c("a", "b", "c", "e", "?"))
  )
  meta <- list(reference = ref)
  pkg <- as_pkgdown(test_path("assets/reference"), override = meta)

  expect_snapshot(data_reference_index(pkg))
})

test_that("can use markdown in title and subtitle", {
  ref <- list(
    list(title = "*A*"),
    list(subtitle = "*B*"),
    list(contents = c("a", "b", "c", "e", "?"))
  )
  meta <- list(reference = ref)
  pkg <- as_pkgdown(test_path("assets/reference"), override = meta)

  data <- data_reference_index(pkg)
  expect_equal(data$rows[[1]]$title, "<em>A</em>")
  expect_equal(data$rows[[2]]$subtitle, "<em>B</em>")
})

test_that("rows with title internal are dropped", {
  ref <- list(
    list(title = "internal", contents = c("a", "b")),
    list(contents = c("c", "e", "?")),
    list(title = "internal")
  )
  meta <- list(reference = ref)
  pkg <- as_pkgdown(test_path("assets/reference"), override = meta)

  expect_warning(index <- data_reference_index(pkg), NA)
  expect_equal(length(index$rows), 1)
})

test_that("duplicate entries within a group is dropped", {
  ref <- list(
    list(contents = c("a", "b", "a", "a")),
    list(contents = c("b", "c", "?", "e"))
  )
  meta <- list(reference = ref)
  pkg <- as_pkgdown(test_path("assets/reference"), override = meta)

  index <- data_reference_index(pkg)
  expect_equal(length(index$rows[[1]]$topics), 2)
  expect_equal(length(index$rows[[2]]$topics), 4)
})

test_that("warns if missing topics", {
  ref <- list(
    list(contents = c("a", "b"))
  )
  meta <- list(reference = ref)
  pkg <- as_pkgdown(test_path("assets/reference"), override = meta)

  expect_snapshot(data_reference_index(pkg), error = TRUE)
})

test_that("default reference includes all functions, only escaping non-syntactic", {
  ref <- default_reference_index(test_path("assets/reference"))
  expect_equal(ref[[1]]$contents, c("a", "b", "c", "e", "`?`"))
})

test_that("gives informative errors", {
  data_reference_index_ <- function(x) {
    pkg <- local_pkgdown_site(meta = list(reference = x))
    data_reference_index(pkg)
  }

  expect_snapshot(error = TRUE, {
    data_reference_index_(1)
    data_reference_index_(list(1))
    data_reference_index_(list(list(title = 1)))
    data_reference_index_(list(list(title = "a\n\nb")))
    data_reference_index_(list(list(subtitle = 1)))
    data_reference_index_(list(list(subtitle = "a\n\nb")))
    data_reference_index_(list(list(title = "bla", contents = 1)))
    data_reference_index_(list(list(title = "bla", contents = NULL)) )
    data_reference_index_(list(list(title = "bla", contents = list("a", NULL))))
    data_reference_index_(list(list(title = "bla", contents = list())))
    data_reference_index_(list(list(title = "bla", contents = "notapackage::lala")))
    data_reference_index_(list(list(title = "bla", contents = "rlang::lala")))
  })
})

test_that("can exclude topics", {
  pkg <- local_pkgdown_site(
    test_path("assets/reference"),
    list(
      reference = list(
        list(title = "Exclude", contents = c("a", "b", "-a")),
        list(title = "Exclude multiple", contents = c("a", "b", "c", "-matches('a|b')")),
        list(title = "Everything else", contents = c("a", "c", "e", "?"))
      )
    )
  )

  ref <- data_reference_index(pkg)
  # row 1 is the title row
  expect_equal(length(ref$rows[[2]]$topics), 1)
  expect_equal(ref$rows[[2]]$topics[[1]]$aliases, "b()")
  expect_equal(length(ref$rows[[4]]$topics), 1)
  expect_equal(ref$rows[[4]]$topics[[1]]$aliases, "c()")
})

test_that("can use a topic from another package", {
  pkg <- local_pkgdown_site(meta = list(reference = list(
    list(title = "bla", contents = c("rlang::is_installed()", "bslib::bs_add_rules"))
  )))

  expect_snapshot(data_reference_index(pkg))
})

test_that("can use a selector name as a topic name", {
  pkg <- local_pkgdown_site(
    test_path("assets/reference-selector"),
    list(
      reference = list(
        list(title = "bla", contents = c("matches", "matches('A')"))
      )
    )
  )

  expect_snapshot(data_reference_index(pkg))
})
