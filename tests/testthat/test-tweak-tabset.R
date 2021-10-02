test_that("sections with class .tabset are converted to tabsets", {
  html <- markdown_to_html("
    # Tabset {.tabset .tabset-pills}

    ## Tab 1

    Contents 1

    ## Tab 2

    Contents 2
  ")

  tweak_tabsets(html)
  tweak_strip_header_class(html) # older pandoc compatibility
  expect_snapshot_output(show_xml(html, ".//div"))
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
  tweak_strip_header_class(html) # older pandoc compatibility
  expect_snapshot_output(show_xml(html, ".//div"))
})

test_that("can fades", {
  html <- markdown_to_html("
    ## Tabset {.tabset .tabset-fade}

    ### Tab 1

    Contents 1

    ### Tab 2 {.active}

    Contents 2
  ")

  tweak_tabsets(html)
  tweak_strip_header_class(html) # older pandoc compatibility
  expect_snapshot_output(show_xml(html, ".//div"))
})
