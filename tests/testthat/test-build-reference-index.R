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

test_that("default reference includes all functions", {
  ref <- default_reference_index(test_path("assets/reference"))
  expect_equal(ref[[1]]$contents, paste0("`", c(letters[1:3], "e", "?"), "`"))
})

test_that("errors well when a content entry is empty", {
  meta <- yaml::yaml.load( "reference:\n- title: bla\n  contents:\n  - aname\n  - ")
  pkg <- as_pkgdown(test_path("assets/reference"), override = meta)

  expect_snapshot_error(build_reference_index(pkg))
})

test_that("errors well when a content entry is not a character", {
  local_edition(3)
  meta <- yaml::yaml.load( "reference:\n- title: bla\n  contents:\n  - aname\n  - N")
  pkg <- as_pkgdown(test_path("assets/reference"), override = meta)

  expect_snapshot(build_reference_index(pkg), error = TRUE)
})

test_that("errors well when a content entry refers to a not installed package", {
  skip_if_not_installed("cli", "3.1.0")
  local_edition(3)

  meta <- yaml::yaml.load( "reference:\n- title: bla\n  contents:\n  - notapackage::lala")
  pkg <- as_pkgdown(test_path("assets/reference"), override = meta)

  expect_snapshot(build_reference_index(pkg), error = TRUE)
})

test_that("errors well when a content entry refers to a non existing function", {
  local_edition(3)
  meta <- yaml::yaml.load( "reference:\n- title: bla\n  contents:\n  - rlang::lala")
  pkg <- as_pkgdown(test_path("assets/reference"), override = meta)

  expect_snapshot(build_reference_index(pkg), error = TRUE)
})

test_that("can exclude topics", {
  pkg <- local_pkgdown_site(test_path("assets/reference"), meta = "
    reference:
    - title: Exclude
      contents: [a, b, -a]
    - title: Exclude multiple
      contents: [a, b, c, -matches('a|b')]
    - title: Everything else
      contents: [a, c, e, '?']
  ")

  ref <- data_reference_index(pkg)
  # row 1 is the title row
  expect_equal(length(ref$rows[[2]]$topics), 1)
  expect_equal(ref$rows[[2]]$topics[[1]]$aliases, "b()")
  expect_equal(length(ref$rows[[4]]$topics), 1)
  expect_equal(ref$rows[[4]]$topics[[1]]$aliases, "c()")
})

test_that("can use a topic from another package", {
  meta <- list(reference = list(list(
    title = "bla",
    contents = c("a", "b", "c", "e", "?", "rlang::is_installed()", "bslib::bs_add_rules")
  )))
  pkg <- as_pkgdown(test_path("assets/reference"), override = meta)

  expect_snapshot(data_reference_index(pkg))
})

test_that("can use a selector name as a topic name", {
  meta <- list(reference = list(list(
    title = "bla",
    contents = c("matches", "matches('A')")
  )))
  pkg <- as_pkgdown(test_path("assets/reference-selector"), override = meta)

  expect_snapshot(data_reference_index(pkg))
})
