test_that("data_news works as expected for h1 & h2", {
  skip_if_no_pandoc()

  lines_h1 <- c(
    "# testpackage 1.0.0.9000", "",
    "* bullet (#222 @someone)", "",
    "# testpackage 1.0.0", "",
    "## sub-heading", "",
    "* first thing (#111 @githubuser)", "",
    "* second thing", ""
  )
  lines_h2 <- gsub("^#", "##", lines_h1)

  pkg <- local_pkgdown_site(meta = "
    template:
      bootstrap: 5
  ")

  write_lines(lines_h1, file.path(pkg$src_path, "NEWS.md"))
  expect_snapshot_output(data_news(pkg)[c("version", "page", "anchor")])

  write_lines(lines_h2, file.path(pkg$src_path, "NEWS.md"))
  expect_snapshot_output(data_news(pkg)[c("version", "page", "anchor")])
})


test_that("multi-page news are rendered", {
  skip_if_no_pandoc()
  local_edition(3)

  pkg <- local_pkgdown_site(meta = "
    news:
      one_page: false
    "
  )
  write_lines(file.path(pkg$src_path, "NEWS.md"), text = c(
    "# testpackage 2.0", "",
    "* bullet (#222 @someone)", "",
    "# testpackage 1.1", "",
    "* bullet (#222 @someone)", "",
    "# testpackage 1.0.1", "",
    "* bullet (#222 @someone)", "",
    "# testpackage 1.0.0", "",
    "## sub-heading", "",
    "* first thing (#111 @githubuser)", "",
    "* second thing"
  ))

  expect_snapshot(data_news(pkg)[c("version", "page", "anchor")])
  expect_snapshot(build_news(pkg))

  # test that index links are correct
  lines <- read_lines(path(pkg$dst_path, "news", "index.html"))
  expect_true(any(grepl("<a href=\"news-2.0.html\">Version 2.0</a>", lines)))

  # test single page structure
  lines <- read_lines(path(pkg$dst_path, "news", "news-1.0.html"))
  expect_true(any(grepl("<h1 data-toc-skip>Changelog <small>1.0</small></h1>", lines)))
})


test_that("github links are added to news items", {
  skip_if_no_pandoc()

  temp_pkg <- list(
    src_path = withr::local_tempdir(pattern = "pkgdown-news"),
    bs_version = 5,
    repo = list(
      url = list(
        home = "https://github.com/r-lib/pkgdown",
        user = "https://github.com/",
        issue = "https://github.com/r-lib/pkgdown/issues/"
      )
    )
  )

  write_lines(
    c(
      "# testpackage 0.1.0", "",
      "## Major changes", "",
      "- Bug fixes (@hadley, #100)", "",
      "- Merges (@josue-rodriguez)"
    ),
    file.path(temp_pkg$src_path, "NEWS.md")
  )
  news_tbl <- data_news(temp_pkg)
  html <- xml2::read_xml(news_tbl$html)

  expect_equal(
    xpath_attr(html, ".//a", "href"),
    c(
      "https://github.com/hadley",
      "https://github.com/r-lib/pkgdown/issues/100",
      "https://github.com/josue-rodriguez"
    )
  )
})

test_that("pkg_timeline fails cleanly for unknown package", {
  skip_on_cran()
  expect_null(pkg_timeline("__XYZ__"))
})

test_that("correct timeline for first ggplot2 releases", {
  skip_on_cran()

  timeline <- pkg_timeline("ggplot2")[1:3, ]
  expected <- data.frame(
    version = c("0.5", "0.5.1", "0.5.2"),
    date = as.Date(c("2007-06-01", "2007-06-09", "2007-06-18")),
    stringsAsFactors = FALSE
  )

  expect_equal(timeline, expected)
})

test_that("determines page style from meta", {
  expect_equal(news_style(meta = list()), "single")
  expect_equal(news_style(meta = list(news = list(one_page = FALSE))), "multi")
  expect_equal(news_style(meta = list(news = list(list(one_page = FALSE)))), "multi")
})

# news_title and version_page -----------------------------------------------

test_that("can recognise common forms of title", {
  # Variants in beginning
  version <- news_version(c(
    "foo 1.3.0",
    "foo v1.3.0",
    "foo 1.3.0",
    "VERSION 1.3.0",
    "changes in 1.3.0",
    "changes in foo version 1.3.0"
  ), "foo")
  expect_equal(version, rep("1.3.0", length(version)))

  # Variants in version spec
  expect_equal(
    news_version(c("foo 1-2", "foo 1-2-3", "foo 1-2-3-4"), "foo"),
    c("1-2", "1-2-3", "1-2-3-4")
  )

  expect_equal(
    news_version("foo (development version)", "foo"),
    "development version"
  )
})

test_that("correctly collapses version to page for common cases", {
  versions <- c("1.0.0", "1.0.0.0", "1.0.0.9000", "development version")
  pages <- purrr::map_chr(versions, version_page)
  expect_equal(pages, c("1.0", "1.0", "dev", "dev"))
})

# Tweaks ------------------------------------------------------------------

test_that("sections tweaked down a level", {
  html <- xml2::read_xml("<body>
    <div class='section level1'><h1></h1></div>
    <div class='section level2'><h2></h2></div>
    <div class='section level3'><h3></h3></div>
    <div class='section level4'><h4></h4></div>
    <div class='section level5'><h5></h5></div>
  </body>")
  tweak_section_levels(html)
  expect_equal(xml2::xml_name(xpath_xml(html, "//div/*")), paste0("h", 2:6))
  expect_equal(xpath_attr(html, "//div", "class"), paste0("section level", 2:6))
})

test_that("anchors de-duplicated with version", {
  html <- xml2::read_xml("<body>
    <div class='section' id='x-1'>Heading</div>
  </body>")
  tweak_news_anchor(html, "1.0")

  expect_equal(xpath_attr(html, ".//div", "id"), "x-1-0")
})

test_that("news headings get class and release date", {
  timeline <- tibble::tibble(version = "1.0", date = "2020-01-01")

  html <- xml2::read_xml("<div><h2></h2></div>")
  tweak_news_heading(html, version = "1.0", timeline = timeline, bs_version = 3)
  expect_snapshot_output(xpath_xml(html, "//div"))

  html <- xml2::read_xml("<div><h2></h2></div>")
  tweak_news_heading(html, version = "1.0", timeline = timeline, bs_version = 4)
  expect_snapshot_output(xpath_xml(html, "//div"))
})

# Header checks ----------------------------------------------------------
test_that("clear error for bad hierarchy - bad nesting", {
  temp_pkg <- list(
    src_path = withr::local_tempdir(pattern = "pkgdown-news"),
    bs_version = 5
  )

  write_lines(
    c(
      "### testpackage 1.0.0.9000", "",
      "* bullet (#222 @someone)", "",
      "# testpackage 1.0.0", "",
      "## sub-heading", "",
      "* first thing (#111 @githubuser)", "",
      "* second thing", ""
    ),
    file.path(temp_pkg$src_path, "NEWS.md")
  )

  expect_snapshot_error(data_news(temp_pkg))
})

test_that("clear error for bad hierarchy - h3", {
  temp_pkg <- list(
    src_path = withr::local_tempdir(pattern = "pkgdown-news"),
    bs_version = 5
  )

  write_lines(
    c(
      "### testpackage 1.0.0.9000", "",
      "* bullet (#222 @someone)", "",
      "### testpackage 1.0.0", "",
      "#### sub-heading", "",
      "* first thing (#111 @githubuser)", "",
      "* second thing", ""
    ),
    file.path(temp_pkg$src_path, "NEWS.md")
  )

  expect_snapshot_error(data_news(temp_pkg))
})

test_that("news can contain footnotes", {
  pkg <- local_pkgdown_site()
  write_lines(path = file.path(pkg$src_path, "NEWS.md"), c(
    "## testpackage 1.0.0.9000",
    "",
    "* bullet",
    "",
    "* inline footnote^[used to fail] ",
    ""
  ))

  expect_snapshot(x <- data_news(pkg))
})

test_that("data_news warns if no headings found", {
  skip_if_no_pandoc()

  lines <- c(
    "# mypackage", "",
    "## mypackage foo", "",
    "## mypackage bar", ""
  )
  pkg <- local_pkgdown_site(meta = "
    template:
      bootstrap: 5
  ")

  write_lines(lines, file.path(pkg$src_path, "NEWS.md"))
  expect_snapshot(. <- data_news(pkg))
})
