context("test-template-content")

# Open Graph ------------------------------------------

test_that("og tags are populated on home, reference, and articles", {
  skip_if_no_pandoc()

  pkg <- as_pkgdown(test_path("assets/open-graph"))
  setup(expect_output(build_site(pkg, new_process = FALSE)))
  on.exit(clean_site(pkg))
  on.exit(dir_delete(path(pkg$src_path, "pkgdown")))

  index_html <- read_lines(path(pkg$dst_path, "index.html"))
  desc <- '<meta property="og:description" content="A longer statement about the package.">'
  expect_true(desc %in% index_html)
  img <- '<meta property="og:image" content="http://example.com/pkg/logo.png">'
  expect_true(img %in% index_html)

  pork_html <- read_lines(path(pkg$dst_path, "reference", "f.html"))
  desc <- '<meta property="og:description" content="Title" />'
  expect_true(desc %in% pork_html)
  img <- '<meta property="og:image" content="http://example.com/pkg/logo.png" />'
  expect_true(img %in% pork_html)

  vignette_html <- read_lines(path(pkg$dst_path, "articles", "open-graph.html"))
  desc <- '<meta property="og:description" content="The Open Graph protocol is a standard for web page metadata.">'
  expect_true(desc %in% vignette_html)
  img <- '<meta property="og:image" content="http://example.com/pkg/logo.png">'
  expect_true(img %in% vignette_html)
})

test_that("if there is no logo.png, there is no og:image tag", {
  skip_if_no_pandoc()

  pkg <- as_pkgdown(test_path("assets/home-readme-rmd"))
  expect_output(build_site(pkg, new_process = FALSE))
  on.exit(clean_site(pkg))

  index_html <- read_lines(path(pkg$dst_path, "index.html"))
  expect_false(any(grepl("og:image", index_html, fixed = TRUE)))
})


describe("open graph tags", {
  skip_if_no_pandoc()
  pkg <- as_pkgdown(test_path("assets/open-graph-customized"))
  setup(expect_output(build_site(pkg, new_process = FALSE)))
  on.exit(clean_site(pkg))

  desc <- '<meta property="og:description" content="A longer statement about the package.">'
  img <- '<meta property="og:image" content="http://example.com/pkg/reference/figures/card.png">'
  img_alt <- '<meta property="og:image:alt" content="The social media card of the example.com package">'
  twitter_creator <- '<meta name="twitter:creator" content="@hadley">'
  # twitter_site is taken from opengraph$twitter if not otherwise specified
  twitter_site <- '<meta name="twitter:site" content="@rstudio">'
  twitter_card <- '<meta name="twitter:card" content="summary_large_image">'

  it("OpenGraph tags are populated on home (index.html)", {
    index_html <- read_lines(path(pkg$dst_path, "index.html"))
    img_tag <- grep('property="og:image"', index_html, fixed = TRUE, value = TRUE)
    expect_true(desc %in% index_html)
    expect_equal(img_tag, img)
    expect_true(img_alt %in% index_html)
    expect_true(twitter_creator %in% index_html)
    expect_true(twitter_site %in% index_html)
    expect_true(twitter_card %in% index_html)
  })

  it("OpenGraph tags are populated in reference pages", {
    pork_html <- read_lines(path(pkg$dst_path, "reference", "f.html"))
    desc <- '<meta property="og:description" content="Title" />'
    escape_gt <- function(x) sub(">", " />", x)
    expect_true(desc %in% pork_html)
    expect_true(escape_gt(img) %in% pork_html)
    expect_true(escape_gt(img_alt) %in% pork_html)
    expect_true(escape_gt(twitter_creator) %in% pork_html)
    expect_true(escape_gt(twitter_site) %in% pork_html)
    expect_true(escape_gt(twitter_card) %in% pork_html)
  })

  it("OpenGraph tags are populated in articles", {
    vignette_html <- read_lines(path(pkg$dst_path, "articles", "open-graph.html"))
    desc <- '<meta property="og:description" content="The Open Graph protocol is a standard for web page metadata.">'
    img_vig <- '<meta property="og:image" content="http://example.com/pkg/batpig.png">'
    twitter_creator_vig <- '<meta name="twitter:creator" content="@dataandme">'
    twitter_card_vig <- '<meta name="twitter:card" content="summary">'
    expect_true(desc %in% vignette_html)
    expect_true(img_vig %in% vignette_html)
    expect_true(img_alt %in% vignette_html)
    expect_true(twitter_creator_vig %in% vignette_html)
    expect_true(twitter_site %in% vignette_html)
    expect_true(twitter_card_vig %in% vignette_html)
  })
})
