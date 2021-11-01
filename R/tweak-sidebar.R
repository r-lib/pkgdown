tweak_sidebar_html <- function(html, sidebar) {
  if (!sidebar) {
    return(html)
  }

  dev_status_html <- html %>% xml2::xml_find_first(".//div[@class='dev-status']")
  if (!inherits(dev_status_html, "xml_node")) {
    return(html)
  }

  badges <- badges_extract(html)
  if (length(badges) == 0) {
    xml2::xml_remove(dev_status_html)
    return(html)
  }

  list <- sidebar_section(tr_("Dev status"), badges)
  list_html <- list %>% xml2::read_html(encoding = "UTF-8") %>% xml2::xml_find_first(".//div")
  xml2::xml_replace(dev_status_html, list_html)
  html
}
