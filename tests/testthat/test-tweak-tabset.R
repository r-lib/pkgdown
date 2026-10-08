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

test_that("Quarto sections with class .tabset are converted to tabsets", {
  html <- xml2::read_html(
    '<section class="level2 tabset">
      <h2 id="tabset" class="tabset">Tabset</h2>
      <section class="level3"><h3 id="tab-1">Tab 1</h3><p>Contents 1</p></section>
      <section class="level3"><h3 id="tab-2">Tab 2</h3><p>Contents 2</p></section>
    </section>'
  )
  tweak_tabsets(html)

  expect_equal(xpath_text(html, "//button"), c("Tab 1", "Tab 2"))
  expect_equal(
    xpath_attr(html, "//div[@class = 'tab-content']/*", "id"),
    c("tab-1", "tab-2")
  )
  expect_equal(
    xpath_attr(html, "//div[@class = 'tab-content']/*", "class"),
    c("active  tab-pane", "tab-pane")
  )
})

test_that("Quarto panel tabsets are converted to tabsets", {
  html <- xml2::read_html(
    '<div class="panel-tabset">
      <ul id="tabset-1" class="panel-tabset-tabby"><li><a data-tabby-default="" href="#tabset-1-1">Tab <code>1</code></a></li><li><a href="#tabset-1-2">Tab 2</a></li></ul>
      <div class="tab-content">
        <div id="tabset-1-1"><p>Contents 1</p></div>
        <div id="tabset-1-2"><p>Contents 2</p></div>
      </div>
    </div>'
  )
  tweak_tabsets(html)

  expect_snapshot_output(xpath_xml(html, ".//body/div"))
})

test_that("Quarto panel tabsets respect default tab and pills", {
  html <- xml2::read_html(
    '<div class="panel-tabset nav-pills">
      <ul id="tabset-1" class="panel-tabset-tabby"><li><a href="#tabset-1-1">Tab 1</a></li><li><a data-tabby-default="" href="#tabset-1-2">Tab 2</a></li></ul>
      <div class="tab-content">
        <div id="tabset-1-1"><p>Contents 1</p></div>
        <div id="tabset-1-2" class="active"><p>Contents 2</p></div>
      </div>
    </div>'
  )
  tweak_tabsets(html)

  expect_equal(xpath_attr(html, "//ul", "class"), "nav nav-pills")
  expect_equal(
    xpath_attr(html, "//button", "class"),
    c("nav-link", "nav-link active")
  )
  expect_equal(
    xpath_attr(html, "//div[@class = 'tab-content']/div", "class"),
    c("tab-pane", "active tab-pane")
  )
})

test_that("Quarto panel tabsets activate first tab by default", {
  html <- xml2::read_html(
    '<div class="panel-tabset">
      <ul id="tabset-1" class="panel-tabset-tabby"><li><a href="#tabset-1-1">Tab 1</a></li><li><a href="#tabset-1-2">Tab 2</a></li></ul>
      <div class="tab-content">
        <div id="tabset-1-1"><p>Contents 1</p></div>
        <div id="tabset-1-2"><p>Contents 2</p></div>
      </div>
    </div>'
  )
  tweak_tabsets(html)

  expect_equal(
    xpath_attr(html, "//button", "aria-selected"),
    c("true", "false")
  )
  expect_equal(
    xpath_attr(html, "//div[@class = 'tab-content']/div", "class"),
    c("active tab-pane", "tab-pane")
  )
})
