#' Build the index page.
#'
build_index <- function(package) {
  out <- file.path(package$base_path, "index.html")
  message("Generating index.html")

  index <- package$index
  topic_index <- package$topics[package$topics$in_index, , drop = FALSE]
  package$topic_index <- rows_list(topic_index)

  # Cross-reference complete list of topics vs. topics found in index page
  topics <- unlist(lapply(index, "[[", "topics"))
  missing <- !(topics %in% topic_index$alias)
  if (any(missing)) {
    warning("Can't find index topics: ", paste(topics[missing], 
      collapse = ", "), call. = FALSE)
    topics <- topics[!missing]
  }
  
  other <- !(topic_index$alias %in% topics)
  if (any(other)) {
    index <- c(index, 
      list(sd_section("Other", NULL, topic_index$alias[other])))
  }
  
  # Render each section
  sections <- lapply(index, build_section, package = package)
  package$sections <- sections
  
  render_template("index", package, out)
}

#' @importFrom markdown markdownToHTML
build_section <- function(section, package) {
  find_info <- function(item) {
    match <- package$topics$alias == item$name
    if (!any(match)) return(NULL)
    
    row <- package$topics[match, , drop = FALSE]
    item$file_out <- row$file_out
    
    if (is.null(item$title)) {
      rd <- package$rd[[row$file_in]]
      item$title <- extract_title(rd)
    }
    item
  }
  
  desc <- section$description
  
  list(
    title = section$name %||% "Missing section title",
    description = if (!is.null(desc)) markdownToHTML(text = desc) else "",
    items = compact(lapply(section$elements, find_info))
  )
}

extract_title <- function(x) {
  alias <- Find(function(x) attr(x, "Rd_tag") == "\\title", x)
  alias[[1]][[1]]
}

compact <- function (x) Filter(Negate(is.null), x)

