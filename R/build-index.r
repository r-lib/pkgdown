# Must be called after all other build functions.
build_index <- function(pkg) {
  out <- file.path(pkg$site_path, "index.html")
  message("Generating index.html")

  index <- pkg$index
  topic_index <- pkg$topics[pkg$topics$in_index, , drop = FALSE]
  pkg$topic_index <- rows_list(topic_index)

  # Cross-reference complete list of topics vs. topics found in index page
  topics <- unlist(lapply(index, "[[", "topics"))
  missing <- !(topics %in% topic_index$name)
  if (any(missing)) {
    warning("Can't find index topics: ", paste(topics[missing],
      collapse = ", "), call. = FALSE)
    topics <- topics[!missing]
  }

  other <- !(topic_index$name %in% topics)
  if (any(other)) {
  title <- if(length(topics)) 'Other' else ''
  index <-
    c(index, list(sd_section(title, NULL, sort(topic_index$name[other]))))
  }

  # Render each section
  sections <- lapply(index, build_section, pkg = pkg)
  pkg$sections <- sections
  pkg$rd <- NULL

  render_icons(pkg)
  pkg$pagetitle <- "Index"
  render_page(pkg, "index", pkg, out)
}

build_section <- function(section, pkg) {
  find_info <- function(item) {
    match <- pkg$topics$name == item$name
    if (!any(match)) return(NULL)

    row <- pkg$topics[match, , drop = FALSE]
    item$file_out <- row$file_out

    aliases <- setdiff(row$alias[[1]], row$name)
    if (length(aliases) > 0) {
      item$aliases <- str_c("(", str_c(aliases, collapse = ", "), ")")
    }

    if (is.null(item$title)) {
      rd <- pkg$rd[[row$file_in]]
      item$title <- extract_title(rd, pkg)
    }

    item$icon <- icon_path(pkg, item$name)
    item
  }

  desc <- section$description

  list(
    title = section$name %||% "Missing section title",
    description = markdown(desc),
    items = compact(lapply(section$elements, find_info))
  )
}

extract_title <- function(x, pkg) {
  alias <- Find(function(x) attr(x, "Rd_tag") == "\\title", x)
  alias <- to_html(alias, pkg)
  alias <- gsub("\\s*\n", " ", alias)
  alias
}

compact <- function (x) Filter(function(x) !is.null(x) & length(x), x)

