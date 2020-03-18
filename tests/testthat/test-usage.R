context("test-usage.R")

test_that("can parse data", {
  usage <- parse_usage("f")[[1]]
  expect_equal(usage, list(type = "data", name = "f"))

  usage <- parse_usage("data(f)")[[1]]
  expect_equal(usage, list(type = "data", name = "f"))
})

test_that("can parse function/methods", {
  usage <- parse_usage("f(x)")[[1]]
  expect_equal(usage$type, "fun")
  expect_equal(usage$name, "f")

  usage <- parse_usage("\\method{f}{bar}(x)")[[1]]
  expect_equal(usage$type, "s3")
  expect_equal(usage$name, "f")
  expect_equal(usage$signature, "bar")

  usage <- parse_usage("\\S3method{f}{bar}(x)")[[1]]
  expect_equal(usage$type, "s3")
  expect_equal(usage$name, "f")
  expect_equal(usage$signature, "bar")

  usage <- parse_usage("\\S4method{f}{bar,baz}(x)")[[1]]
  expect_equal(usage$type, "s4")
  expect_equal(usage$name, "f")
  expect_equal(usage$signature, c("bar", "baz"))

  usage <- parse_usage("\\S4method{f}{NULL}(x)")[[1]]
  expect_equal(usage$type, "s4")
  expect_equal(usage$name, "f")
  expect_equal(usage$signature, c("NULL"))

  usage <- parse_usage("pkg::func()")[[1]]
  expect_equal(usage$type, "fun")
  expect_equal(usage$name, "func")

  usage <- parse_usage("pkg:::func()")[[1]]
  expect_equal(usage$type, "fun")
  expect_equal(usage$name, "func")
})

test_that("can parse replacement functions", {
  usage <- parse_usage("f() <- value")[[1]]
  expect_true(usage$replacement)
  expect_equal(usage$name, "f<-")

  usage <- parse_usage("\\S3method{f}{bar}(x) <- value")[[1]]
  expect_true(usage$replacement)
  expect_equal(usage$name, "f<-")

  usage <- parse_usage("\\S4method{f}{bar,baz}(x) <- value")[[1]]
  expect_true(usage$replacement)
  expect_equal(usage$name, "f<-")
})

test_that("can parse infix functions", {
  usage <- parse_usage("x \\%f\\% y")[[1]]
  expect_true(usage$infix)
  expect_equal(usage$name, "%f%")

  usage <- parse_usage("\\S3method{[}{bar}(x)")[[1]]
  expect_true(usage$infix)
  expect_equal(usage$name, "[")

  usage <- parse_usage("\\S4method{[}{bar,baz}(x)")[[1]]
  expect_true(usage$infix)
  expect_equal(usage$name, "[")
})

test_that("can parse infix replacement functions", {
  usage <- parse_usage("\\S3method{[}{bar}(x) <- value")[[1]]
  expect_true(usage$infix)
  expect_true(usage$replacement)
  expect_equal(usage$name, "[<-")

  usage <- parse_usage("\\S4method{[}{bar,baz}(x) <- value")[[1]]
  expect_true(usage$infix)
  expect_true(usage$replacement)
  expect_equal(usage$name, "[<-")
})

test_that("can parse multistatement usages", {
  usage <- parse_usage("f()\n%This is a comment\ng(\n\n)")
  expect_length(usage, 2)

  expect_equal(usage[[1]]$name, "f")
  expect_equal(usage[[2]]$name, "g")
})

test_that("can parse dots", {
  usage <- parse_usage("f(\\dots)")[[1]]
  expect_equal(usage$name, "f")
})

# short_name --------------------------------------------------------------

test_that("infix functions left as", {
  expect_equal(short_name("%||%", "fun"), "`%||%`")
})

test_that("function name and signature is escaped", {
  expect_equal(short_name("%<%", "fun"), "`%&lt;%`")
  expect_equal(short_name("f", "S3", "<"), "f(<i>&lt;&lt;&gt;</i>)")
})
