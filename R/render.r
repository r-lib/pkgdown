#' Render complete page.
#' 
#' @param name of the template (e.g. index, demo, topic)
#' @param data data for the template
#' @param path location to create file.  If \code{""} (the default), 
#'   prints to standard out.
#' @export
render_page <- function(name, data, path = "") {
  # render template components
  pieces <- c("head", "navbar", "header", "content", "footer")
  components <- lapply(pieces, render_template, name, data)
  names(components) <- pieces
  
  # render complete layout
  out <- render_template("layout", name, components)
  cat(out, file = path)
}

#' @importFrom whisker whisker.render
render_template <- function(type, name, data) {
  template <- readLines(find_template(type, name))
  if (length(template) <= 1 && str_trim(template) == "") return("")
  
  whisker.render(template, data)
}

find_template <- function(type, name) {
  base_path <- file.path(inst_path(), "templates")
  
  # look for most specific first
  spec <- file.path(base_path, str_c(type, "-", name, ".html")) 
  if (file.exists(spec)) return(spec)
  
  base <- file.path(base_path, str_c(type, ".html"))
  if (file.exists(base)) return(base)
  
  stop("Can't find template for ", type, "-", name, ".", call. = FALSE)
}
