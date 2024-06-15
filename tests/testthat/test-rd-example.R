# run_examples() -----------------------------------------------------------

test_that("warns if unparseable", {
  expect_warning(
    run_examples("1 + \\dontrun{2 + }"),
    "Failed to parse"
  )
})

# as_example() ------------------------------------------------------------

test_that("dontrun{} wrapped in if(FALSE)", {
  expect_equal(rd2ex("\\dontrun{1}"), "if (FALSE) 1 # \\dontrun{}")
  expect_equal(
    rd2ex("\\dontrun{\n  1\n}"),
    c("if (FALSE) { # \\dontrun{", "  1", "} # }")
  )

  # unless run_dont_run is true
  expect_equal(rd2ex("\\dontrun{1}", run_dont_run = TRUE), "1")
  expect_equal(
    rd2ex("\\dontrun{\n  1\n}", run_dont_run = TRUE),
    c("# \\dontrun{", "  1", "# }")
  )
})

test_that("block donttest{} gets a comment to preserve spacing", {
  expect_equal(rd2ex("\\donttest{1}"), "1")
  expect_equal(
    rd2ex("\\donttest{\n  1\n}"),
    c("# \\donttest{", "  1", "# }")
  )
})

test_that("dontshow{} becomes DONTSHOW", {
  expect_equal(rd2ex("\\dontshow{1}"), "DONTSHOW({1})")
  expect_equal(rd2ex("\\dontshow{\n  1\n}"), c("DONTSHOW({", "  1", "})"))
})

test_that("testonly{} becomes TESTONLY", {
  expect_equal(rd2ex("\\testonly{1}"), "TESTONLY({1})")
  expect_equal(rd2ex("\\testonly{\n  1\n}"), c("TESTONLY({", "  1", "})"))
})

test_that("handles nested tags", {
  expect_equal(
    rd2ex("if(TRUE {\n  \\dontrun{\n    1 + 2\n  }\n}"),
    c(
      "if(TRUE {",
      "  if (FALSE) { # \\dontrun{",
      "    1 + 2",
      "  } # }",
      "}"
    )
  )
})

test_that("translate dots and ldots to ...", {
  expect_equal(rd2ex("\\ldots"), "...")
  expect_equal(rd2ex("\\dots"), "...")
})

test_that("ignores out", {
  expect_equal(rd2ex("\\out{1 + 2}"), "1 + 2")
})

test_that("extracts conditions from if", {
  expect_equal(rd2ex("\\if{html}{1 + 2}"), "1 + 2")
  expect_equal(rd2ex("\\if{latex}{1 + 2}"), "")
  expect_equal(rd2ex("\\ifelse{html}{1 + 2}{3 + 4}"), "1 + 2")
  expect_equal(rd2ex("\\ifelse{latex}{1 + 2}{3 + 4}"), "3 + 4")
})

test_that("@examplesIf", {

  rd <- paste0(
    "\\dontshow{if (1 == 0) (if (getRversion() >= \"3.4\") withAutoprint else force)(\\{ # examplesIf}\n",
    "answer <- 43\n",
    "\\dontshow{\\}) # examplesIf}"
  )
  exp <- c(
    "if (FALSE) { # 1 == 0",
    "answer <- 43",
    "}"
  )
  expect_warning(
    expect_equal(rd2ex(rd), exp),
    "@examplesIf condition"
  )

  rd2 <- paste0(
    "\\dontshow{if (TRUE) (if (getRversion() >= \"3.4\") withAutoprint else force)(\\{ # examplesIf}\n",
    "answer <- 43\n",
    "\\dontshow{\\}) # examplesIf}"
  )
  exp2 <- c(
    "answer <- 43"
  )
  expect_equal(rd2ex(rd2), exp2)

  cnd <- paste0(strrep("TRUE && ", 100), "FALSE")
  rd3 <- paste0(
    "\\dontshow{if (", cnd, ") (if (getRversion() >= \"3.4\") withAutoprint else force)(\\{ # examplesIf}\n",
    "answer <- 43\n",
    "\\dontshow{\\}) # examplesIf}"
  )
  exp3 <- c(
    paste0("if (FALSE) { # ", cnd),
    "answer <- 43",
    "}"
  )
  expect_snapshot(
    expect_equal(strtrim(rd2ex(rd3), 40), strtrim(exp3, 40))
  )
})
