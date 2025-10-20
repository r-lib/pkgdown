simplify_dls <- function(html) {
  dls <- xml2::xml_find_all(html, ".//dl")
  for (dl in dls) {
    simplify_dl(dl)
  }
  invisible()
}

simplify_dl <- function(dl) {
  children <- xml2::xml_children(dl)

  names <- xml2::xml_name(children)
  if (!is_simple_dl(names)) {
    cli::cli_warn("Skipping this <dl>: not a simple term-definition list")
    return()
  }

  groups <- split(children, (seq_along(children) - 1) %/% 2)

  bullets <- lapply(groups, create_li_from_group)
  ul <- xml2::read_xml("<ul></ul>")
  xml_insert(ul, bullets)

  xml2::xml_replace(dl, ul)
}

# Must have an even number of children that alternate between dt and dd
is_simple_dl <- function(names) {
  if (length(names) %% 2 != 0) {
    return(FALSE)
  }
  odd <- names[seq_along(names) %% 2 == 1]
  even <- names[seq_along(names) %% 2 == 0]

  all(odd == "dt") && all(even == "dd")
}

create_li_from_group <- function(group) {
  dt <- group[[1]]
  dd <- group[[2]]

  if (has_children(dd)) {
    # params case
    para <- xml2::read_xml("<p></p>")
    xml_insert(para, xml2::xml_contents(dt))
    xml2::xml_add_child(para, xml_text_node(": "))

    bullet <- xml2::read_xml("<li></li>")
    xml2::xml_add_child(bullet, para)
  } else {
    # reference index
    bullet <- xml2::read_xml("<li></li>")
    xml_insert(bullet, xml2::xml_contents(dt))
    xml2::xml_add_child(bullet, xml_text_node(": "))
  }
  xml_insert(bullet, xml2::xml_contents(dd))

  bullet
}

has_children <- function(x) length(xml2::xml_children(x)) > 0

xml_text_node <- function(x) {
  span <- xml2::read_xml(paste0("<span>", x, "</span>"))
  xml2::xml_find_first(span, ".//text()")
}
