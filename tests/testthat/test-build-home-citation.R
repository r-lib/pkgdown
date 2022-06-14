# A CITATION file anywhere except in `inst/CITATION` is an R CMD check note
# so 'site-citation' is build-ignored, and so the tests must be skipped
# during R CMD check

path <- test_path("assets/site-citation/encoding-UTF-8")
skip_if_not(dir_exists(path)[[1]])

test_that("UTF-8 encoding and `citation(auto = meta) can be read` (#416, #493)", {
  cit <- read_citation(test_path("assets/site-citation/encoding-UTF-8"))
  expect_s3_class(cit, "citation")
})

test_that("latin1 encoding and `citation(auto = meta) can be read` (#689)", {
  cit <- read_citation(test_path("assets/site-citation/encoding-latin1"))
  expect_s3_class(cit, "citation")
})

test_that("create_meta can read DESCRIPTION with an Encoding", {
  meta <- create_citation_meta(test_path("assets/site-citation/encoding-UTF-8"))
  expect_type(meta, "list")
  expect_equal(meta$`Authors@R`, 'person(\"Florian\", \"Privé\")')
})

test_that("source link is added to citation page", {
  pkg <- local_pkgdown_site(test_path("assets/site-citation/encoding-UTF-8"))
  expect_output(build_home(pkg))

  lines <- read_lines(path(pkg$dst_path, "authors.html"))
  expect_true(any(grepl("<code>inst/CITATION</code></a></small>", lines)))
})

test_that("multiple citations all have HTML and BibTeX formats", {
  citations <- data_citations(test_path("assets/site-citation/multi"))
  expect_snapshot_output(citations)
})

test_that("links in curly braces in authors comments are escaped", {
  pkg_dir <- withr::local_tempdir()
  desc <- desc::description$new(cmd = "!new")
  desc$add_author("Jane", "Doe", comment = "reviewed see <https://github.com/r-lib/pkgdown/pulls>")
  desc$write(file.path(pkg_dir, "DESCRIPTION"))
  authors_data <- data_authors(pkg_dir)
  expect_equal(
    authors_data$all[[2]]$comment,
    "reviewed see &lt;<a href='https://github.com/r-lib/pkgdown/pulls'>https://github.com/r-lib/pkgdown/pulls</a>&gt;"
  )
})
