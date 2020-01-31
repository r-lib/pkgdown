context("test-template-content")

n_matches <- function(page, pattern) {
  length(grep(pattern, page, fixed = TRUE, value = TRUE))
}

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

  index_html_path <- path(pkg_tmp_dir, "index.html")
  expect_output(render_page(pkg, "home", data_home(pkg), path = index_html_path))
  index_html <- read_lines(index_html_path)
  expect_false(any(grepl("og:image", index_html, fixed = TRUE)))
})


describe("customized open graph tags", {
  skip_if_no_pandoc()
  pkg <- as_pkgdown(test_path("assets/open-graph-customized"))
  pkg_tmp_dir <- dir_create(file_temp("pkgdown-open-graph"))
  pkg$dst_path <- pkg_tmp_dir
  on.exit(unlink(pkg_tmp_dir))

  desc <- '<meta property="og:description" content="A longer statement about the package."'
  img <- '<meta property="og:image" content="http://example.com/pkg/reference/figures/card.png"'
  img_alt <- '<meta property="og:image:alt" content="The social media card of the example.com package"'
  twitter_creator <- '<meta name="twitter:creator" content="@hadley"'
  # twitter_site is taken from opengraph$twitter if not otherwise specified
  twitter_site <- '<meta name="twitter:site" content="@rstudio"'
  twitter_card <- '<meta name="twitter:card" content="summary_large_image"'

  it("OpenGraph tags are populated on home (index.html)", {
    index_html_path <- path(pkg_tmp_dir, "index.html")
    expect_output(render_page(pkg, "home", data_home(pkg), path = index_html_path))
    index_html <- read_lines(index_html_path)

    expect_equal(n_matches(index_html, desc), 1)
    expect_equal(n_matches(index_html, img), 1)
    expect_equal(n_matches(index_html, img_alt), 1)
    expect_equal(n_matches(index_html, twitter_creator), 1)
    expect_equal(n_matches(index_html, twitter_site), 1)
    expect_equal(n_matches(index_html, twitter_card), 1)
  })

  it("OpenGraph tags are populated in reference pages", {
    ref_page_path <- path(pkg_tmp_dir, "reference", "f.html")
    dir_create(pkg_tmp_dir, "reference")
    with_dir(
      pkg_tmp_dir,
      expect_output(build_reference(pkg, preview = FALSE))
    )
    ref_page <- read_lines(ref_page_path)
    desc <- '<meta property="og:description" content="Title"'

    expect_equal(n_matches(ref_page, desc), 1)
    expect_equal(n_matches(ref_page, img), 1)
    expect_equal(n_matches(ref_page, img_alt), 1)
    expect_equal(n_matches(ref_page, twitter_creator), 1)
    expect_equal(n_matches(ref_page, twitter_site), 1)
    expect_equal(n_matches(ref_page, twitter_card), 1)
  })

  it("OpenGraph tags are populated in articles", {
    dir_create(pkg_tmp_dir, "articles")
    expect_output(build_article("open-graph", pkg = pkg, quiet = TRUE))
    articles_page_path <- path(pkg_tmp_dir, "articles", "open-graph.html")
    articles_page <- read_lines(articles_page_path)

    desc <- '<meta property="og:description" content="The Open Graph protocol is a standard for web page metadata."'
    img_vig <- '<meta property="og:image" content="http://example.com/pkg/batpig.png"'
    twitter_creator_vig <- '<meta name="twitter:creator" content="@dataandme"'
    twitter_card_vig <- '<meta name="twitter:card" content="summary"'

    expect_equal(n_matches(articles_page, desc), 1)
    expect_equal(n_matches(articles_page, img_vig), 1)
    expect_equal(n_matches(articles_page, img_alt), 1)
    expect_equal(n_matches(articles_page, twitter_creator_vig), 1)
    expect_equal(n_matches(articles_page, twitter_site), 1)
    expect_equal(n_matches(articles_page, twitter_card_vig), 1)
  })
})
