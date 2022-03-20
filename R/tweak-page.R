# File level tweaks --------------------------------------------
tweak_page <- function(html, name, pkg = list(bs_version = 3)) {
  # Syntax highlighting and linking
  if (name == "reference-topic") {
    # Reference topic takes a minimal approach since some is
    # already handled by Rd processing
    tweak_reference_highlighting(html)
  } else {
    downlit::downlit_html_node(html)

    # Rescue highlighting of non-collapsed output - needed for ANSI escapes
    pre <- xml2::xml_find_all(html, ".//pre[not(contains(@class, 'downlit'))]")
    is_wrapped <- is_wrapped_pre(pre)
    purrr::walk(pre[!is_wrapped], tweak_highlight_r)
  }

  tweak_anchors(html)
  tweak_link_md(html)
  tweak_link_external(html, pkg = pkg)
  tweak_img_src(html)
  tweak_strip(html, !identical(pkg$development$mode, "release"))

  # BS3 uses table for layout of reference-index
  if (name != "reference-index") {
    tweak_tables(html)
  }

  if (pkg$bs_version > 3) {
    tweak_footnotes(html)
    tweak_tabsets(html)
    tweak_useless_toc(html)
  }

  if (!is.null(pkg$desc) && pkg$desc$has_dep("R6")) {
    tweak_link_R6(html, pkg$package)
  }
}

tweak_rmarkdown_html <- function(html, input_path, pkg = list(bs_version = 3)) {
  # Tweak classes of navbar
  toc <- xml2::xml_find_all(html, ".//div[@id='tocnav']//ul")
  xml2::xml_attr(toc, "class") <- "nav nav-pills nav-stacked"

  # Make sure all images use relative paths
  img <- xml2::xml_find_all(html, "//img")
  src <- xml2::xml_attr(img, "src")
  abs_src <- is_absolute_path(src)
  if (any(abs_src)) {
    purrr::walk2(
      img[abs_src],
      path_rel(src[abs_src], input_path),
      xml2::xml_set_attr,
      attr = "src"
    )
  }

  # If top-level headings use h1, move everything down one level
  h1 <- xml2::xml_find_all(html, "//h1")
  if (length(h1) > 1) {
    tweak_section_levels(html)
  }

  # Has to occur after path normalisation
  # This get called twice on the contents of content-article.html, but that
  # should be harmless
  tweak_page(html, "article", pkg = pkg)

  invisible()
}

tweak_homepage_html <- function(html,
                                strip_header = FALSE,
                                sidebar = TRUE,
                                bs_version = 3,
                                logo = NULL) {

  html <- tweak_sidebar_html(html, sidebar = sidebar)

  # Always remove dummy page header
  header <- xml2::xml_find_all(html, ".//div[contains(@class, 'page-header')]")
  if (length(header) > 0)
    xml2::xml_remove(header, free = TRUE)

  header <- xml2::xml_find_first(html, ".//h1")
  if (strip_header) {
    page_header <- xml2::xml_remove(header, free = TRUE)
  } else {
    page_header <- xml2::xml_add_parent(header, "div", class = "page-header")
  }

  if (!is.null(logo) && bs_version > 3) {
    # Remove logo if added to h1
    # Bare image
    xml2::xml_remove(xml2::xml_find_all(html, ".//h1/img[contains(@src, 'logo')]"))

    # Image in link
    xml2::xml_remove(
      xml2::xml_parent(
        xml2::xml_find_all(html, ".//h1/a/img[contains(@src, 'logo')]")
      )
    )

    # Add back to header
    xml2::xml_add_sibling(page_header, "img",
      src = logo,
      class = "logo",
      alt = "",
      .where = "before"
    )
  }

  invisible()
}

# Strip off #toc if it's not needed; easier to do this here than in js
tweak_useless_toc <- function(html) {
  contents <- xml2::xml_find_all(html, ".//main")
  headings <- xml2::xml_find_all(contents, ".//h2|.//h3|.//h4|.//h5|.//h6")

  if (length(headings) > 1) {
    return()
  }

  toc <- xml2::xml_find_first(html, '//nav[@id="toc"]')
  sidebar <- xml2::xml_parent(toc)
  if (length(xml2::xml_children(sidebar)) == 1) {
    xml2::xml_remove(sidebar)
  } else {
    xml2::xml_remove(toc)
  }
}


# Update file on disk -----------------------------------------------------

update_html <- function(path, tweak, ...) {

  raw <- read_file(path)
  # Following the xml 1.0 spec, libxml2 drops low-bit ASCII characters
  # so we convert to \u2029, relying on downlit to convert back in
  # token_escape().
  raw <- gsub("\033", "\u2029", raw, fixed = TRUE)
  html <- xml2::read_html(raw, encoding = "UTF-8")
  tweak(html, ...)

  xml2::write_html(html, path, format = FALSE)
  path
}
