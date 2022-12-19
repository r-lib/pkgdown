test_that("test setting one hook", {
  html <- xml2::read_html('
    <a href="local.md"></a>
    <a href="http://remote.com/remote.md"></a>
  ')

  setHook("UserHook::pkgdown::test_hook", function(...) {tweak_link_md(..1)}, "replace")

  call_hook("test_hook", html)

  expect_equal(
    xpath_attr(html, "//a", "href"),
    c("local.html", "http://remote.com/remote.md")
  )
})

test_that("test multi hook for applying execution", {
  html <- xml2::read_html('
    <body>
    <a href="local.md"></a>
    <a href="http://remote.com/remote.md"></a>
    <img src="https://raw.githubusercontent.com/OWNER/REPO/main/vignettes/foo" />
    <img src="https://github.com/OWNER/REPO/raw/main/man/figures/foo" />
    </body>
  ')
  urls_before <- xpath_attr(html, ".//img", "src")

  setHook("UserHook::pkgdown::test_hook", function(...) {tweak_link_md(..1)}, "replace")
  setHook("UserHook::pkgdown::test_hook", function(...) {tweak_img_src(..1)}, "append")

  call_hook("test_hook", html)

  expect_equal(
    xpath_attr(html, ".//img", "src"),
    urls_before
  )
  expect_equal(
    xpath_attr(html, "//a", "href"),
    c("local.html", "http://remote.com/remote.md")
  )
})
