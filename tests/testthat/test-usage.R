
# Reference --------------------------------------------------------------------

test_that("usage escapes special characters", {
  # parseable
  expect_equal(usage2text("# <"), "# &lt;")
  #unparseable
  expect_equal(usage2text("<"), "&lt;")
})

test_that("usage re-renders non-syntactic calls", {
  expect_equal(usage2text("`<`(x, y)"), "x &lt; y")
  expect_equal(usage2text("`[`(x, y)"), "x[y]")
})

test_that("usage doesn't re-renders syntactic calls", {
  expect_equal(usage2text("foo(x , y) # hi"), "foo(x , y) # hi")

  multi_line <- "foo(\n  x # x,\n  y = 1 # y,\n)"
  expect_equal(usage2text(multi_line), multi_line)
})

test_that("usage generates user facing code for S3/S4 infix/replacement methods", {
  expect_snapshot({
    cat(usage2text("\\S3method{$}{indexed_frame}(x, name)"))
    cat(usage2text("\\method{[[}{indexed_frame}(x, i) <- value"))
    cat(usage2text("\\S4method{>=}{MyType,numeric}(e1, e2)"))
  })
})

test_that("S4 methods gets comment", {
  out <- rd2html("\\S4method{fun}{class}(x, y)")
  expect_equal(out[1], "# S4 method for class 'class'")
  expect_equal(out[2], "fun(x, y)")
})

test_that("S3 methods gets comment", {
  out <- rd2html("\\S3method{fun}{class}(x, y)")
  expect_equal(out[1], "# S3 method for class 'class'")
  expect_equal(out[2], "fun(x, y)")

  out <- rd2html("\\method{fun}{class}(x, y)")
  expect_equal(out[1], "# S3 method for class 'class'")
  expect_equal(out[2], "fun(x, y)")
})

test_that("Methods for class function work", {
  out <- rd2html("\\S3method{fun}{function}(x, y)")
  expect_equal(out[1], "# S3 method for class 'function'")
  expect_equal(out[2], "fun(x, y)")

  out <- rd2html("\\method{fun}{function}(x, y)")
  expect_equal(out[1], "# S3 method for class 'function'")
  expect_equal(out[2], "fun(x, y)")

  out <- rd2html("\\S4method{fun}{function,function}(x, y)")
  expect_equal(out[1], "# S4 method for class 'function,function'")
  expect_equal(out[2], "fun(x, y)")
})

test_that("default methods get custom text", {
  out <- rd2html("\\S3method{fun}{default}(x, y)")
  expect_equal(out[1], "# Default S3 method")

  out <- rd2html("\\S4method{fun}{default}(x, y)")
  expect_equal(out[1], "# Default S4 method")
})

test_that("non-syntactic functions get backquoted, not escaped", {
  out <- rd2html("\\S3method{<}{foo}(x, y)")
  expect_equal(out[[2]], "`<`(x, y)")

  out <- rd2html("\\S4method{bar<-}{foo}(x, y)")
  expect_equal(out[[2]], "`bar<-`(x, y)")
})

# Reference index --------------------------------------------------------------

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

  usage <- parse_usage("\\S3method{f}{`foo bar`}(x)")[[1]]
  expect_equal(usage$type, "s3")
  expect_equal(usage$name, "f")
  expect_equal(usage$signature, "foo bar")

  usage <- parse_usage("\\S4method{f}{bar,baz}(x)")[[1]]
  expect_equal(usage$type, "s4")
  expect_equal(usage$name, "f")
  expect_equal(usage$signature, c("bar", "baz"))

  usage <- parse_usage("\\S4method{f}{NULL}(x)")[[1]]
  expect_equal(usage$type, "s4")
  expect_equal(usage$name, "f")
  expect_equal(usage$signature, c("NULL"))

  usage <- parse_usage("\\S4method{f}{function,function}(x, y)")[[1]]
  expect_equal(usage$type, "s4")
  expect_equal(usage$name, "f")
  expect_equal(usage$signature, c("function", "function"))

  usage <- parse_usage("\\S4method{f}{function,foo bar}(x, y)")[[1]]
  expect_equal(usage$type, "s4")
  expect_equal(usage$name, "f")
  expect_equal(usage$signature, c("function", "foo bar"))

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
