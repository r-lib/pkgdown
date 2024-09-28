# File level tweaks --------------------------------------------
tweak_page <- function(html, name, pkg = list(bs_version = 3)) {
  # Syntax highlighting and linking
  if (name == "reference-topic") {
    # Reference topic takes a minimal approach since some is
    # already handled by Rd processing
    tweak_reference_highlighting(html)
    tweak_extra_logo(html)
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
    img_target_nodes <- img[abs_src]
    img_src_real <- path_real(xml2::url_unescape(src[abs_src]))
    input_path_real <- path_real(xml2::url_unescape(input_path))
    img_rel_paths <- path_rel(path = img_src_real, start = input_path_real)
    img_rel_paths <- xml2::url_escape(img_rel_paths)

    purrr::walk2(
      .x = img_target_nodes,
      .y = img_rel_paths,
      .f = xml2::xml_set_attr,
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

read_html_keep_ansi <- function(path) {
  raw <- read_file(path)
  # Following the xml 1.0 spec, libxml2 drops low-bit ASCII characters
  # so we convert to \u2029, relying on downlit to convert back in
  # token_escape().
  raw <- gsub("\033", "\u2029", raw, fixed = TRUE)
  # Use charToRaw() to always interpret as string,
  # even for length 1 vectors
  xml2::read_html(charToRaw(raw), encoding = "UTF-8")
}

update_html <- function(path, tweak, ...) {
  html <- read_html_keep_ansi(path)
  tweak(html, ...)

  xml2::write_html(html, path, format = FALSE)
  path
}
