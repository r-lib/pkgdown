context("test-template-content")

n_matches <- function(page, pattern) {
  length(grep(pattern, page, fixed = TRUE, value = TRUE))
}

# Open Graph ------------------------------------------

test_that("opengraph tags are populated on home, reference, and articles", {
  skip_if_no_pandoc()

  pkg <- as_pkgdown(test_path("assets/open-graph"))
  pkg_tmp_dir <- dir_create(file_temp("pkgdown-open-graph-standard"))
  pkg$dst_path <- pkg_tmp_dir
  on.exit(unlink(pkg_tmp_dir))

  # opengrah tags are populated on home page
  index_html_path <- path(pkg_tmp_dir, "index.html")
  expect_output(render_page(pkg, "home", data_home(pkg), path = index_html_path))

  index_html <- read_lines(index_html_path)
  desc <- '<meta property="og:description" content="A longer statement about the package."'
  img <- '<meta property="og:image" content="http://example.com/pkg/logo.png"'
  expect_equal(n_matches(index_html, desc), 1)
  expect_equal(n_matches(index_html, img), 1)

  # opengrah tags are populated in reference pages
  ref_page_path <- path(pkg_tmp_dir, "reference", "f.html")
  dir_create(pkg_tmp_dir, "reference")
  with_dir(
    pkg_tmp_dir,
    expect_output(build_reference(pkg, examples = FALSE, topics = "f"))
  )
  ref_html <- read_lines(ref_page_path)

  desc <- '<meta property="og:description" content="Title" />'
  img <- '<meta property="og:image" content="http://example.com/pkg/logo.png" />'
  expect_equal(n_matches(ref_html, desc), 1)
  expect_equal(n_matches(ref_html, img), 1)

  # opengraph tags are populated in vignettes
  dir_create(pkg_tmp_dir, "articles")
  expect_output(build_article("open-graph", pkg = pkg, quiet = TRUE))
  vignette_html_path <- path(pkg_tmp_dir, "articles", "open-graph.html")
  vignette_html <- read_lines(vignette_html_path)

  desc <- '<meta property="og:description" content="The Open Graph protocol is a standard for web page metadata.">'
  img <- '<meta property="og:image" content="http://example.com/pkg/logo.png">'
  expect_equal(n_matches(vignette_html, desc), 1)
  expect_equal(n_matches(vignette_html, img), 1)
})

test_that("if there is no logo.png, there is no og:image tag", {
  skip_if_no_pandoc()

  pkg <- as_pkgdown(test_path("assets/home-readme-rmd"))
  pkg_tmp_dir <- dir_create(file_temp("pkgdown-no-logo"))
  pkg$dst_path <- pkg_tmp_dir
  on.exit(unlink(pkg_tmp_dir))

  index_html_path <- path(pkg_tmp_dir, "index.html")
  expect_output(render_page(pkg, "home", data_home(pkg), path = index_html_path))
  index_html <- read_lines(index_html_path)
  expect_false(any(grepl("og:image", index_html, fixed = TRUE)))
})


test_that("customized open graph tags are populated on home, reference, and articles", {
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

  # OpenGraph tags are populated on home (index.html)
  index_html_path <- path(pkg_tmp_dir, "index.html")
  expect_output(render_page(pkg, "home", data_home(pkg), path = index_html_path))
  index_html <- read_lines(index_html_path)

  expect_equal(n_matches(index_html, desc), 1)
  expect_equal(n_matches(index_html, img), 1)
  expect_equal(n_matches(index_html, img_alt), 1)
  expect_equal(n_matches(index_html, twitter_creator), 1)
  expect_equal(n_matches(index_html, twitter_site), 1)
  expect_equal(n_matches(index_html, twitter_card), 1)

  # OpenGraph tags are populated in reference pages
  ref_page_path <- path(pkg_tmp_dir, "reference", "f.html")
  dir_create(pkg_tmp_dir, "reference")
  with_dir(
    pkg_tmp_dir,
    expect_output(build_reference(pkg, examples = FALSE, topics = "f"))
  )
  ref_page <- read_lines(ref_page_path)
  desc <- '<meta property="og:description" content="Title"'

  expect_equal(n_matches(ref_page, desc), 1)
  expect_equal(n_matches(ref_page, img), 1)
  expect_equal(n_matches(ref_page, img_alt), 1)
  expect_equal(n_matches(ref_page, twitter_creator), 1)
  expect_equal(n_matches(ref_page, twitter_site), 1)
  expect_equal(n_matches(ref_page, twitter_card), 1)

  # OpenGraph tags are populated in articles
  dir_create(pkg_tmp_dir, "articles")
  expect_warning(
    expect_output(build_article("open-graph", pkg = pkg, quiet = TRUE)),
    "Unsupported `opengraph` field:"
  )
  articles_page_path <- path(pkg_tmp_dir, "articles", "open-graph.html")
  articles_page <- read_lines(articles_page_path)

  title <- '<meta property="og:title" content="Introduction to Open Graph"'
  desc <- '<meta property="og:description" content="The Open Graph protocol is a standard for web page metadata."'
  img_vig <- '<meta property="og:image" content="http://example.com/pkg/batpig.png"'
  twitter_creator_vig <- '<meta name="twitter:creator" content="@dataandme"'
  twitter_card_vig <- '<meta name="twitter:card" content="summary"'

  expect_equal(n_matches(articles_page, title), 1)
  expect_equal(n_matches(articles_page, desc), 1)
  expect_equal(n_matches(articles_page, img_vig), 1)
  expect_equal(n_matches(articles_page, img_alt), 1)
  expect_equal(n_matches(articles_page, twitter_creator_vig), 1)
  expect_equal(n_matches(articles_page, twitter_site), 1)
  expect_equal(n_matches(articles_page, twitter_card_vig), 1)

  # default article description is the package title
  expect_output(build_article("no-description", pkg = pkg, quiet = TRUE))
  no_desc_page_path <- path(pkg_tmp_dir, "articles", "no-description.html")
  no_desc_page <- read_lines(no_desc_page_path)

  title <- '<meta property="og:title" content="No Description"'
  desc <- '<meta property="og:description" content="testpackage"'

  expect_equal(n_matches(no_desc_page, title), 1)
  expect_equal(n_matches(no_desc_page, desc), 1)
  expect_equal(n_matches(no_desc_page, img), 1)     # site-wide default
  expect_equal(n_matches(no_desc_page, img_alt), 1) # site-wide default
  expect_equal(n_matches(no_desc_page, twitter_creator_vig), 1)
  expect_equal(n_matches(no_desc_page, twitter_site), 1)
  expect_equal(n_matches(no_desc_page, twitter_card_vig), 1)
})

og_exp <- list(
  image = list(src = "logo.png", alt = "logo"),
  twitter = list(creator = "@hadley", site = "@rstudio", card = "summary_card")
)

test_that("check_open_graph() errors when opengraph is not a list", {
  expect_error(check_open_graph("@hadley"), "must be a list")
})

test_that("check_open_graph() returns only supported items", {
  expect_identical(check_open_graph(og_exp), og_exp)

  og_extra <- og_exp
  og_extra$description <- "nope"
  expect_identical(
    expect_warning(check_open_graph(og_extra), "`opengraph` field:"),
    og_exp
  )

  og_extra$facebook <- "nope again"
  expect_identical(
    expect_warning(check_open_graph(og_extra), "`opengraph` fields:"),
    og_exp
  )
})

test_that("check_open_graph() aborts when `twitter` has unexpected structure", {
  og_exp$twitter <- list(card = "summary_card")
  expect_error(check_open_graph(og_exp), "twitter.+must include.+creator.+site")

  og_exp$twitter <- "@hadley"
  expect_error(check_open_graph(og_exp), "twitter.+must be a list")
})

test_that("check_open_graph() errors when `image` has unexpected structure", {
  og_exp$image <- "logo.png"
  expect_error(check_open_graph(og_exp), "image.+must be a list\\. Did you mean")

  og_exp$image <- c("logo.png", "logo2.png")
  expect_error(check_open_graph(og_exp), "image.+must be a list")
})
