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

test_that("rows with title internal are dropped", {
  ref <- list(
    list(title = "internal"),
    list(contents = c("a", "b", "c", "e", "?")),
    list(title = "internal")
  )
  meta <- list(reference = ref)
  pkg <- as_pkgdown(test_path("assets/reference"), override = meta)

  index <- data_reference_index(pkg)
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

  withr::local_envvar(c(CI = "false"))
  expect_warning(data_reference_index(pkg), "Topics missing")

  withr::local_envvar(c(CI = "true"))
  expect_error(data_reference_index(pkg), "Topics missing")
})

test_that("default reference includes all functions", {
  ref <- default_reference_index(test_path("assets/reference"))
  expect_equal(ref[[1]]$contents, paste0("`", c(letters[1:3], "e", "?"), "`"))
})

test_that("errors well when a content entry is not a character", {
  meta <- yaml::yaml.load( "reference:\n- title: bla\n  contents:\n  - N")
  pkg <- as_pkgdown(test_path("assets/reference"), override = meta)

  expect_snapshot_error(build_reference_index(pkg))
})

test_that("errors well when a content entry refers to a not installed package", {
  skip_if_not_installed("rlang", "0.99")
  skip_if_not_installed("cli", "3.1.0")

  meta <- yaml::yaml.load( "reference:\n- title: bla\n  contents:\n  - notapackage::lala")
  pkg <- as_pkgdown(test_path("assets/reference"), override = meta)

  expect_snapshot_error(build_reference_index(pkg))
})

test_that("errors well when a content entry refers to a non existing function", {
  meta <- yaml::yaml.load( "reference:\n- title: bla\n  contents:\n  - rlang::lala")
  pkg <- as_pkgdown(test_path("assets/reference"), override = meta)

  expect_snapshot_error(build_reference_index(pkg))
})


test_that("can use a topic from another package", {
  meta <- list(reference = list(list(
    title = "bla",
    contents = c("a", "b", "c", "e", "?", "rlang::is_installed()", "bslib::bs_add_rules")
  )))
  pkg <- as_pkgdown(test_path("assets/reference"), override = meta)

  expect_snapshot(data_reference_index(pkg))
})
