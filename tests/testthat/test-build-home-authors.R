test_that("authors page includes inst/AUTHORS", {
  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(pkg, "inst/AUTHORS", "Hello")
  suppressMessages(build_citation_authors(pkg))

  lines <- read_lines(path(pkg$dst_path, "authors.html"))
  expect_match(lines, "<pre>Hello</pre>", all = FALSE)
})

test_that("data_authors validates yaml inputs", {
  data_authors_ <- function(...) {
    pkg <- local_pkgdown_site(meta = list(...))
    data_authors(pkg)
  }

  expect_snapshot(error = TRUE, {
    data_authors_(authors = 1)
    data_authors_(authors = list(before = 1))
    data_authors_(authors = list(after = 1))
  })
})

test_that("data_home_sidebar_authors validates yaml inputs", {
  data_home_sidebar_authors_ <- function(...) {
    pkg <- local_pkgdown_site(meta = list(...))
    data_home_sidebar_authors(pkg)
  }

  expect_snapshot(error = TRUE, {
    data_home_sidebar_authors_(authors = list(sidebar = list(roles = 1)))
    data_home_sidebar_authors_(authors = list(sidebar = list(before = 1)))
    data_home_sidebar_authors_(authors = list(sidebar = list(before = "x\n\ny")))
  })
})

# authors --------------------------------------------------------------------

test_that("ORCID can be identified & removed from all comment styles", {
  desc <- desc::desc(text = c(
    'Authors@R: c(',
    '    person("no comment"),',
    '    person("bare comment", comment = "comment"),',
    '    person("orcid only",   comment = c(ORCID = "1")),',
    '    person("both",         comment = c("comment", ORCID = "2"))',
    '  )'
  ))
  authors <- purrr::map(desc$get_authors(), author_list, list())
  expect_equal(
    purrr::map(authors, "orcid"),
    list(NULL, NULL, orcid_link("1"), orcid_link("2"))
  )

  expect_equal(
    purrr::map(authors, "comment"),
    list(character(), "comment", character(), "comment")
  )
})

test_that("ROR can be identified & removed from all comment styles", {
  desc <- desc::desc(text = c(
    'Authors@R: c(',
    '    person("no comment"),',
    '    person("bare comment", comment = "comment"),',
    '    person("ror only",   comment = c(ROR = "1")),',
    '    person("both",         comment = c("comment", ROR = "2"))',
    '  )'
  ))
  authors <- purrr::map(desc$get_authors(), author_list, list())
  expect_equal(
    purrr::map(authors, "ror"),
    list(NULL, NULL, ror_link("1"), ror_link("2"))
  )

  expect_equal(
    purrr::map(authors, "comment"),
    list(character(), "comment", character(), "comment")
  )
})

test_that("author comments linkified with escaped angle brackets (#2127)", {
  p <- list(name = "Jane Doe", roles = "rev", comment = "<https://x.org/>")
  expect_match(
    author_desc(p),
    "&lt;<a href='https://x.org/'>https://x.org/</a>&gt;",
    fixed = TRUE
  )
})

test_that("authors data can be filtered with different roles", {
  pkg <- local_pkgdown_site(desc = list(`Authors@R` = '
    c(
    person("Hadley", "Wickham", , "hadley@rstudio.com", role = c("aut", "cre")),
    person("RStudio", role = c("cph", "fnd"))
    )'
  ))
  expect_length(data_authors(pkg)$main, 2)
  expect_length(data_authors(pkg, roles = "cre")$main, 1)
})

test_that("authors data includes inst/AUTHORS", {
  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(pkg, "inst/AUTHORS", "Hello")

  expect_equal(data_authors(pkg)$inst, "Hello")
})

test_that("sidebar can accept additional before and after text", {
  pkg <- local_pkgdown_site()
  pkg$meta$authors$sidebar$before <- "BEFORE"
  pkg$meta$authors$sidebar$after <- "AFTER"
  expect_snapshot(cat(data_home_sidebar_authors(pkg)))
})

test_that("role has multiple fallbacks", {
  expect_equal(role_lookup("cre"), "maintainer")
  expect_equal(role_lookup("res"), "researcher")
  expect_snapshot(role_lookup("unknown"))
})

# citations -------------------------------------------------------------------

test_that("can handle UTF-8 encoding (#416, #493)", {
  # Work around bug in utils::citation()
  local_options(warnPartialMatchDollar = FALSE)

  pkg <- local_pkgdown_site(desc = list(
    Title = "A søphîstiçated påckagé",
    Date = "2018-02-02"
  ))

  meta <- create_citation_meta(pkg$src_path)
  expect_type(meta, "list")
  expect_equal(meta$Title, "A søphîstiçated påckagé")

  pkg <- pkg_add_file(pkg, "inst/CITATION", c(
    'citEntry(',
    '  entry = "Article",',
    '  title="Title: é",',
    '  author="Author: é",',
    '  journal="Journal é",',
    '  year="2017",',
    '  textVersion = "é"',
    ')'
  ))
  cit <- read_citation(pkg$src_path)
  expect_s3_class(cit, "citation")

  pkg <- pkg_add_file(pkg, "inst/CITATION", "citation(auto = meta)")
  cit <- read_citation(pkg$src_path)
  expect_s3_class(cit, "citation")
})

test_that("can handle latin1 encoding (#689)", {
  pkg <- local_pkgdown_site(desc = list(
    Title = "A søphîstiçated påckagé",
    Date = "2018-02-02",
    Encoding = "latin1"
  ))
  meta <- create_citation_meta(pkg$src_path)
  expect_equal(meta$Title, "A søphîstiçated påckagé")
  expect_equal(Encoding(meta$Title), "UTF-8")

  pkg <- pkg_add_file(pkg, "inst/CITATION", c(
    'citEntry(',
    '  entry = "Article",',
    '  title="Title: é",',
    '  author="Author: é",',
    '  journal="Journal é",',
    '  year="2017",',
    '  textVersion = "é"',
    ')'
  ))
  cit_path <- path(pkg$src_path, "inst/CITATION")
  citation <- readLines(cit_path) # nolint
  con <- file(cit_path, open = "w+", encoding = "native.enc")
  withr::defer(close(con))
  base::writeLines(iconv(citation, to = "latin1"), con, useBytes = TRUE) # nolint

  cit <- read_citation(pkg$src_path)
  expect_s3_class(cit, "citation")

  pkg <- pkg_add_file(pkg, "inst/CITATION", "citation(auto = meta)")
  cit <- read_citation(pkg$src_path)
  expect_s3_class(cit, "citation")
})

test_that("source link is added to citation page", {
  # Work around bug in utils::citation()
  local_options(warnPartialMatchDollar = FALSE)

  pkg <- local_pkgdown_site(meta = list(
    repo = list(url = list(source = "http://github.com/test/test"))
  ))
  pkg <- pkg_add_file(pkg, "inst/CITATION", c(
    'citEntry(',
    '  entry = "Article",',
    '  title="Title",',
    '  author="Author",',
    '  journal="Journal",',
    '  year="2020",',
    '  textVersion = ""',
    ')'
  ))
  suppressMessages(build_citation_authors(pkg))

  lines <- read_lines(path(pkg$dst_path, "authors.html"))
  expect_match(lines, "<code>inst/CITATION</code></a>", all = FALSE, fixed = TRUE)
})

test_that("multiple citations all have HTML and BibTeX formats", {
  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(pkg, "inst/CITATION", c(
    'bibentry("misc", title="Proof of b < a > c", author=c("A", "B"), year="2021",
         textVersion="A & B (2021): Proof of b < a > c.")',
    'bibentry("misc", title="Title Two", author="Author Two", year="2022")'
  ))

  citations <- data_citations(pkg$src_path)
  expect_snapshot_output(citations)
})

test_that("bibtex is escaped", {
  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(pkg, "inst/CITATION", c(
    'citEntry(',
    '  entry = "Article",',
    '  title="test special HTML characters: <&>",',
    '  author="x",',
    '  journal="x",',
    '  year="2017",',
    '  textVersion = ""',
    ')'
  ))

  suppressMessages(build_citation_authors(pkg))
  html <- xml2::read_html(path(pkg$dst_path, "authors.html"))

  expect_match(xpath_text(html, "//pre"), "<&>", fixed = TRUE)
})
