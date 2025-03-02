test_that("sections with class .tabset are converted to tabsets", {
  skip_on_os("windows") # some line ending problem
  pkg <- local_pkgdown_site()
  html <- markdown_to_html(
    pkg,
    "
    # Tabset {.tabset .tabset-pills}

    ## Tab 1

    Contents 1

    ## Tab 2

    Contents 2
  "
  )

  tweak_tabsets(html)

  # strip class for older pandoc compat on GHA
  headings <- xml2::xml_find_all(html, ".//h1")
  xml2::xml_set_attr(headings, "class", NULL)

  expect_snapshot_output(xpath_xml(html, ".//body/div"))
})

test_that("can adjust active tab", {
  skip_on_os("windows") # some line ending problem
  pkg <- local_pkgdown_site()
  html <- markdown_to_html(
    pkg,
    "
    ## Tabset {.tabset .tabset-pills}

    ### Tab 1

    Contents 1

    ### Tab 2 {.active}

    Contents 2
  "
  )
  tweak_tabsets(html)

  expect_equal(
    xpath_attr(html, "//div/div/div", "class"),
    c("tab-pane", "active tab-pane")
  )
})

test_that("can fade", {
  pkg <- local_pkgdown_site()
  html <- markdown_to_html(
    pkg,
    "
    ## Tabset {.tabset .tabset-fade}

    ### Tab 1

    Contents 1

    ### Tab 2 {.active}

    Contents 2
  "
  )

  tweak_tabsets(html)
  expect_equal(
    xpath_attr(html, "//div/div/div", "class"),
    c("fade tab-pane", "show active fade tab-pane")
  )
})

test_that("can accept html", {
  pkg <- local_pkgdown_site()
  html <- markdown_to_html(
    pkg,
    "
    ## Tabset {.tabset}

    ### Tab 1 `with_code` {#toc-1}

    Contents 1

    ### <i class=\"fa fab-github\"></i> Tab 2 {#toc-2}

    Contents 2

    ### Normal Tab {#toc-normal}

    Contents of normal tab
  "
  )

  tweak_tabsets(html)

  expect_match(
    as.character(xpath_xml(html, ".//*[@id = 'toc-1-tab']")),
    "Tab 1 <code>with_code</code>",
    fixed = TRUE
  )

  expect_match(
    as.character(xpath_xml(html, ".//*[@id = 'toc-2-tab']")),
    "<i class=\"fa fab-github\"></i> Tab 2",
    fixed = TRUE
  )

  expect_match(
    as.character(xpath_xml(html, ".//*[@id = 'toc-normal-tab']")),
    ">Normal Tab</button>",
    fixed = TRUE
  )
})
