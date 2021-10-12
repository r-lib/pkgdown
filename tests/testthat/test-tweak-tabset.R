test_that("sections with class .tabset are converted to tabsets", {
  html <- markdown_to_html("
    # Tabset {.tabset .tabset-pills}

    ## Tab 1

    Contents 1

    ## Tab 2

    Contents 2
  ")

  tweak_tabsets(html)

  # strip class for older pandoc compat on GHA
  headings <- xml2::xml_find_all(html, ".//h1")
  xml2::xml_set_attr(headings, "class", NULL)

  expect_snapshot_output(xpath_xml(html, ".//body/div"))
})

test_that("can adjust active tab", {
  html <- markdown_to_html("
    ## Tabset {.tabset .tabset-pills}

    ### Tab 1

    Contents 1

    ### Tab 2 {.active}

    Contents 2
  ")
  tweak_tabsets(html)

  expect_equal(
    xpath_attr(html, "//div/div/div", "class"),
    c("tab-pane", "active tab-pane")
  )
})

test_that("can fade", {
  html <- markdown_to_html("
    ## Tabset {.tabset .tabset-fade}

    ### Tab 1

    Contents 1

    ### Tab 2 {.active}

    Contents 2
  ")

  tweak_tabsets(html)
  expect_equal(
    xpath_attr(html, "//div/div/div", "class"),
    c("fade tab-pane", "show active fade tab-pane")
  )
})
