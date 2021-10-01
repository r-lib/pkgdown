
# Tabsets tweaking: find Markdown recommended in https://bookdown.org/yihui/rmarkdown-cookbook/html-tabs.html
# and https://bookdown.org/yihui/rmarkdown/html-document.html#tabbed-sections
# i.e. "## Heading {.tabset}" or "## Heading {.tabset .tabset-pills}"
#  no matter the heading level -- the headings one level down are the tabs
# and transform to tabsets HTML a la Bootstrap

tweak_tabsets <- function(html) {
  tabsets <- xml2::xml_find_all(html, ".//div[contains(@class, 'tabset')]")
  purrr::walk(tabsets, tweak_tabset)
  invisible()
}

tweak_tabset <- function(html) {
  id <- xml2::xml_attr(html, "id")

  # Users can choose pills or tabs
  nav_class <- if (has_class(html, "tabset-pills")) {
    "nav-pills"
  } else {
    "nav-tabs"
  }
  # Users can choose to make content fade
  fade <- has_class(html, "tabset-fade")

  # Get tabs and remove them from original HTML
  tabs <- xml2::xml_find_all(html, "div")
  xml2::xml_remove(tabs)

  # Add empty ul for nav and div for content
  xml2::xml_add_child(
    html,
    "ul",
    class = sprintf("nav %s nav-row", nav_class),
    id = id,
    role = "tablist"
  )
  xml2::xml_add_child(html, "div", class="tab-content")

  # Fill the ul for nav and div for content
  purrr::walk(tabs, tablist_item, html = html, parent_id = id)
  purrr::walk(tabs, tablist_content, html = html, parent_id = id, fade = fade)

  # activate first tab unless another one is already activated
  # (by the attribute {.active} in the source Rmd)
  nav_links <- xml2::xml_find_all(html, sprintf("//ul[@id='%s']/li/a", id))

  if (!any(has_class(nav_links, "active"))) {
    tweak_class_prepend(nav_links[1], "active")
  }

  content_div <- xml2::xml_find_first(html, sprintf("//div[@id='%s']/div", id))
  if (!any(has_class(xml2::xml_children(content_div), "active"))) {
    tweak_class_prepend(xml2::xml_child(content_div), "active")
    if (fade) {
      tweak_class_prepend(xml2::xml_child(content_div), "show")
    }
  }
}

# Add an item (tab) to the tablist
tablist_item <- function(tab, html, parent_id) {
  id <- xml2::xml_attr(tab, "id")
  text <- xml_text1(xml2::xml_child(tab))
  ul_nav <- xml2::xml_find_first(html, sprintf("//ul[@id='%s']", parent_id))

  # Activate (if there was "{.active}" in the source Rmd)
  active <- has_class(tab, "active")
  class <- if (active) {
    "nav-link active"
  } else {
    "nav-link"
  }

  xml2::xml_add_child(
    ul_nav,
    "a",
    text,
    `data-toggle` = "tab",
    href = paste0("#", id),
    role = "tab",
    `aria-controls` = id,
    `aria-selected` = tolower(as.character(active)),
    class = class
  )

  # tab a's need to be wrapped in li's
  xml2::xml_add_parent(
    xml2::xml_find_first(html, sprintf("//a[@href='%s']", paste0("#", id))),
    "li",
    role = "presentation",
    class = "nav-item"
  )
}

# Add content of a tab to a tabset
tablist_content <- function(tab, html, parent_id, fade) {
  active <- has_class(tab, "active")

  # remove first child, that is the header
  xml2::xml_remove(xml2::xml_child(tab))

  xml2::xml_attr(tab, "class") <- "tab-pane"
  if (fade) {
    tweak_class_prepend(tab, "fade")
  }

  # Activate (if there was "{.active}" in the source Rmd)
  if (active) {
    tweak_class_prepend(tab, "active")
    if (fade) {
      tweak_class_prepend(tab, "show")
    }
  }

  xml2::xml_attr(tab, "role") <- "tabpanel"
  xml2::xml_attr(tab, " aria-labelledby") <- xml2::xml_attr(tab, "id")

  content_div <- xml2::xml_find_first(
    html,
    sprintf("//div[@id='%s']/div", parent_id)
  )

  xml2::xml_add_child(content_div, tab)
}

