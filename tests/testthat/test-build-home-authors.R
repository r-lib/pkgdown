test_that("ORCID can be identified from all comment styles", {
  desc <- desc::desc(text = c(
    'Authors@R: c(',
    '    person("test no comment"),',
    '    person("test comments no orcid", comment = c("test comment no orcid")),',
    '    person("test bare comment", comment = "test bare comment"),',
    '    person("test orcid only", comment = c(ORCID = "1")),',
    '    person("test comment and orcid", comment = c("test comment and orcid", ORCID = "2"))',
    '  )'
  ))
  authors <- unclass(desc$get_authors())
  authors <- purrr::map(authors, author_list, list())
  orcid <- purrr::map(authors, "orcid")
  expect_equal(orcid, list(NULL, NULL, NULL, orcid_link("1"), orcid_link("2")))
})

test_that("names can be removed from persons", {
  remove_orcid <- function(comment) {
    remove_name(comment, "ORCID")
  }
  expect_equal(remove_orcid(NULL), NULL)
  expect_equal(remove_orcid("one"), "one")
  expect_equal(remove_orcid(c("one", "two")), c("one", "two"))
  expect_equal(remove_orcid(c("one", ORCID = "orcid")), "one")
  expect_equal(remove_orcid(c(ORCID = "orcid")), character())
  expect_equal(remove_orcid(c(ORCID = "orcid1", ORCID = "orcid2")), character())
})

test_that("author comments linkified", {
  p <- list(name = "Jane Doe", roles = "rev", comment = "<https://x.org/>")
  expect_match(author_desc(p), linkify("<https://x.org/>"), fixed = TRUE)
})

test_that("Data authors can accept different filtering", {
  pkg <- as_pkgdown(test_path("assets/sidebar"))
  expect_length(data_authors(pkg)$main, 2)
  expect_length(data_authors(pkg, roles = "cre")$main, 1)
})

test_that("authors data includes inst/AUTHORS", {
  pkg <- as_pkgdown(test_path("assets/inst-authors"))
  expect_equal(data_authors(pkg)$inst, "Hello")
})

test_that("data_home_sidebar_authors() works with text", {
  pkg <- as_pkgdown(test_path("assets/sidebar-comment"))
  pkg$meta$authors$sidebar$before <- "yay"
  pkg$meta$authors$sidebar$after <- "cool"
  expect_snapshot(cat(data_home_sidebar_authors(pkg)))
})

test_that("role has multiple fallbacks", {
  expect_equal(role_lookup("cre"), "maintainer")
  expect_equal(role_lookup("res"), "researcher")
  expect_snapshot(role_lookup("unknown"))
})


# A CITATION file anywhere except in `inst/CITATION` is an R CMD check note
# so 'site-citation' is build-ignored, and so the tests must be skipped
# during R CMD check

test_that("can handle UTF-8 encoding (#416, #493)", {
  # Work around bug in utils::citation()
  local_options(warnPartialMatchDollar = FALSE)

  path <- test_path("assets/site-citation-UTF-8")
  local_citation_activate(path)

  cit <- read_citation(path)
  expect_s3_class(cit, "citation")

  meta <- create_citation_meta(path)
  expect_type(meta, "list")
  expect_equal(meta$`Authors@R`, 'person("Florian", "Privé")')
})

test_that("can handle latin1 encoding (#689)", {
  path <- test_path("assets/site-citation-latin1")
  local_citation_activate(path)

  cit <- read_citation(path)
  expect_s3_class(cit, "citation")
})

test_that("source link is added to citation page", {
  # Work around bug in utils::citation()
  local_options(warnPartialMatchDollar = FALSE)

  path <- test_path("assets/site-citation-UTF-8")
  local_citation_activate(path)

  pkg <- local_pkgdown_site(path)
  suppressMessages(build_home(pkg))

  lines <- read_lines(path(pkg$dst_path, "authors.html"))
  expect_true(any(grepl("<code>inst/CITATION</code></a></small>", lines)))
})

test_that("citation page includes inst/AUTHORS", {
  pkg <- local_pkgdown_site(test_path("assets/inst-authors"))
  suppressMessages(init_site(pkg))
  suppressMessages(build_citation_authors(pkg))

  lines <- read_lines(path(pkg$dst_path, "authors.html"))
  expect_true(any(grepl("<pre>Hello</pre>", lines)))
})

test_that("multiple citations all have HTML and BibTeX formats", {
  path <- test_path("assets/site-citation-multi")
  local_citation_activate(path)

  citations <- data_citations(path)
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

