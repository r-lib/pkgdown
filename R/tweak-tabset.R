# Tabsets tweaking: find Markdown recommended in
# https://bookdown.org/yihui/rmarkdown-cookbook/html-tabs.html
# and https://bookdown.org/yihui/rmarkdown/html-document.html#tabbed-sections
# i.e. "## Heading {.tabset}" or "## Heading {.tabset .tabset-pills}"
#  no matter the heading level -- the headings one level down are the tabs
# and transform to tabsets HTML a la Bootstrap

tweak_tabsets <- function(html) {
  # R Markdown: a <div>, or with Quarto a <section>, whose child sections are
  # the tabs
  tabsets <- xml2::xml_find_all(
    html,
    paste0(
      ".//div",
      xpath_has_class("tabset"),
      "|.//section",
      xpath_has_class("tabset")
    )
  )
  purrr::walk(tabsets, tweak_tabset)

  # Quarto's `::: {.panel-tabset}` is already split into tabs, but using the
  # markup expected by tabby.js, which pkgdown doesn't include
  panel_tabsets <- xml2::xml_find_all(
    html,
    paste0(".//div", xpath_has_class("panel-tabset"))
  )
  purrr::walk(panel_tabsets, tweak_panel_tabset)

  invisible()
}

xpath_has_class <- function(class) {
  paste0(
    "[contains(concat(' ', normalize-space(@class), ' '), ' ",
    class,
    " ')]"
  )
}

tweak_tabset <- function(div) {
  # Get tabs and remove them from original HTML
  tabs <- xml2::xml_find_all(div, "./div|./section")
  xml2::xml_remove(tabs)

  # Add empty ul for nav and div for content
  nav_class <- if (has_class(div, "tabset-pills")) {
    "nav nav-pills"
  } else {
    "nav nav-tabs"
  }
  fade <- has_class(div, "tabset-fade")

  id <- section_id(div)
  nav <- xml2::xml_add_child(
    div,
    "ul",
    class = nav_class,
    id = id,
    role = "tablist"
  )
  content <- xml2::xml_add_child(div, "div", class = "tab-content")

  # Fill the ul for nav and div for content
  purrr::walk(tabs, tablist_item, nav = nav, parent_id = id)
  purrr::walk(
    tabs,
    tablist_content,
    content = content,
    parent_id = id,
    fade = fade
  )

  # if not tabs active, activate the first tab
  if (!any(has_class(xml2::xml_children(content), "active"))) {
    first_tab <- xml2::xml_find_first(nav, ".//li/button")
    tweak_class_prepend(first_tab, "active")
    xml2::xml_attr(first_tab, "aria-selected") <- "true"

    tab_class <- paste("active", if (has_class(div, "tabset-fade")) "show")
    tweak_class_prepend(xml2::xml_child(content), tab_class)
  }
}

# Add an item (tab) to the tablist
tablist_item <- function(tab, nav, parent_id) {
  # Activate (if there was "{.active}" in the source Rmd)
  tablist_button(
    nav,
    id = section_id(tab),
    title = tablist_title(tab),
    active = has_class(tab, "active")
  )
}

tablist_button <- function(nav, id, title, active) {
  li <- xml2::xml_add_child(
    nav,
    "li",
    role = "presentation",
    class = "nav-item"
  )
  button <- xml2::xml_add_child(
    li,
    "button",
    `data-bs-toggle` = "tab",
    `data-bs-target` = paste0("#", id),
    id = paste0(id, "-tab"),
    type = "button",
    role = "tab",
    `aria-controls` = id,
    `aria-selected` = tolower(active),
    class = paste0("nav-link", if (active) " active")
  )

  # Preserve html in title by adding from xml_nodeset item by item
  for (title_item in title) {
    xml2::xml_add_child(button, title_item)
  }

  invisible()
}

tablist_title <- function(tab) {
  # remove anchor link from tab heading
  tab_heading_anchor <- xml2::xml_find_first(tab, ".//a[@class = 'anchor']")
  xml2::xml_remove(tab_heading_anchor)

  xml2::xml_contents(xml2::xml_child(tab))
}

# Add content of a tab to a tabset
tablist_content <- function(tab, content, parent_id, fade) {
  id <- section_id(tab)
  # remove the header, the first child
  xml2::xml_remove(xml2::xml_child(tab))

  xml2::xml_attr(tab, "id") <- id

  # Activate (if there was "{.active}" in the source Rmd)
  active <- has_class(tab, "active")
  tab_class <- c(
    if (fade && active) "show",
    if (active) "active",
    if (fade) "fade",
    "tab-pane"
  )
  xml2::xml_attr(tab, "class") <- paste(tab_class, collapse = " ")

  xml2::xml_attr(tab, "role") <- "tabpanel"
  xml2::xml_attr(tab, "aria-labelledby") <- paste0(id, "-tab")

  xml2::xml_add_child(content, tab)

  invisible()
}

# Quarto panel tabsets ----------------------------------------------------
# https://quarto.org/docs/output-formats/html-basics.html#tabsets
# Quarto generates:
# <div class="panel-tabset">
#   <ul id="tabset-1" class="panel-tabset-tabby">
#     <li><a data-tabby-default href="#tabset-1-1">Tab 1</a></li>
#     <li><a href="#tabset-1-2">Tab 2</a></li>
#   </ul>
#   <div class="tab-content">
#     <div id="tabset-1-1">...</div>
#     <div id="tabset-1-2">...</div>
#   </div>
# </div>
# and we replace the <ul> with Bootstrap tabs, as for R Markdown tabsets.

tweak_panel_tabset <- function(div) {
  tabby <- xml2::xml_find_first(
    div,
    paste0("./ul", xpath_has_class("panel-tabset-tabby"))
  )
  content <- xml2::xml_find_first(
    div,
    paste0("./div", xpath_has_class("tab-content"))
  )
  links <- xml2::xml_find_all(tabby, "./li/a")
  if (inherits(content, "xml_missing") || length(links) == 0) {
    return(invisible())
  }

  ids <- sub("^#", "", xml2::xml_attr(links, "href"))
  active <- xml2::xml_has_attr(links, "data-tabby-default")
  if (!any(active)) {
    active[[1]] <- TRUE
  }

  nav_class <- if (has_class(div, "nav-pills")) {
    "nav nav-pills"
  } else {
    "nav nav-tabs"
  }
  nav <- xml2::xml_add_sibling(
    content,
    "ul",
    class = nav_class,
    id = xml2::xml_attr(tabby, "id"),
    role = "tablist",
    .where = "before"
  )

  for (i in seq_along(links)) {
    tablist_button(
      nav,
      id = ids[[i]],
      title = xml2::xml_contents(links[[i]]),
      active = active[[i]]
    )

    pane <- xml2::xml_find_first(content, paste0("./div[@id='", ids[[i]], "']"))
    xml2::xml_attr(pane, "class") <- if (active[[i]]) {
      "active tab-pane"
    } else {
      "tab-pane"
    }
    xml2::xml_attr(pane, "role") <- "tabpanel"
    xml2::xml_attr(pane, "aria-labelledby") <- paste0(ids[[i]], "-tab")
  }
  xml2::xml_remove(tabby)

  invisible()
}
