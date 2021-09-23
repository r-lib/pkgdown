test_that("urls to inherited methods of R6 classes are correctly modified ", {

  html <- xml2::read_html("
    <!DOCTYPE html>
    <html><body>
    <span class=\"pkg-link\" data-pkg=\"R6test\" data-topic=\"Animal\" data-id=\"initialize\">
    <a href='../../R6test/html/Animal.html#method-initialize'><code>R6test::Animal$initialize()</code></a><code>R6test::Animal$initialize()</code></a>,
    </span>,
    </body></html>"
  )

  pkgdown:::fix_R6_inherited_hrefs(html)
  result <- html %>% xml2::xml_find_all("//*[@href]") %>% xml2::xml_attr("href")

  expect_equal(result, "Animal.html#method-initialize")

  # html without class=\"pkg-link\" is unaffected
  html <- xml2::read_html("
    <!DOCTYPE html>
    <html><body>
    <span class=\"something else\" data-pkg=\"R6test\" data-topic=\"Animal\" data-id=\"initialize\">
    <a href='../../R6test/html/Animal.html#method-initialize'><code>R6test::Animal$initialize()</code></a><code>R6test::Animal$initialize()</code></a>,
    </span>,
    </body></html>"
  )

  pkgdown:::fix_R6_inherited_hrefs(html)
  result <- html %>% xml2::xml_find_all("//*[@href]") %>% xml2::xml_attr("href")
  expect_equal(result, "../../R6test/html/Animal.html#method-initialize")

})
