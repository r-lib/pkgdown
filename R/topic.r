
#' Package topic R documentation.
#'
#' @param package package to explore
#' @param topic topic of the package to retrieve
#' @param file location of the rd database.  If it is \code{NULL}, it will be found.
#' @author Haldey Wickham and Barret Schloerke
#' @keywords internal
#' @return text of the .rd file
pkg_topic <- function(package, topic, file = NULL) {
  if (is.null(file)) {
    topics <- pkg_topics_index(package)
    topic_page <- subset(topics, alias == topic, select = file)$file
    
    if(length(topic_page) < 1)
      topic_page <- subset(topics, file == topic, select = file)$file
    
    stopifnot(length(topic_page) >= 1)
    file <- topic_page[1]    
  }
  
  name_rd(tools:::fetchRdDB(pkg_rddb_path(package), file))
}


#' Name R documentation.
#'
#' @param rd rd file to use
#' @return rd file properly named according to the tags
#' @author Hadley Wickham
#' @keywords internal
name_rd <- function(rd) {
  tags <- sapply(rd, tag)
  tags <- gsub("\\\\", "", tags)
  names(rd) <- tags
  
  rd
} 

#' Internal topic function.
#'
#' @param help \code{pkg_topic(}\emph{\code{topic}}\code{)}  is checked to see if a keyword is "internal"
#' @return boolean
topic_is_internal <- function(help) {
  "internal" %in% help$keywords
}




#' Highlight R text.
#' Highlights R text to include links to all functions and make it easier to read
#' @param parser_output text to be parsed and highlighted
#' @return highlighted text
#' @author Hadley Wickham and Barret Schloerke \email{schloerke@@gmail.com}
#' @keywords internal
highlight <- function(parser_output, source_link = FALSE) {
  if (is.null(parser_output)) return("")
  
  # add links before being sent to be highlighted
  parser_output <- add_function_links_into_parsed(parser_output, source_link)  
  
  str_c(
    capture.output(
      highlight::highlight( 
        parser.output = parser_output, 
        renderer = highlight::renderer_html(doc = F)
      )
    ), 
    collapse = "\n"
  )
}

#' Add funciton link.
#' Add the function link to the preparsed R code
#'
#' @param parser_output pre-parsed output
#' @return parsed output with functions with html links around them
add_function_links_into_parsed <- function(parser_output, source_link = FALSE) {
  # pull out data
  d <- attr(parser_output, "data")
  
#  funcs <- d[d[,"token.desc"] == "SYMBOL_FUNCTION_CALL" ,"text"]
  rows <- with(d, (token.desc == "SYMBOL_FUNCTION_CALL" & ! text %in% c("", "(",")") ) | text %in% c("UseMethod"))

  if (!TRUE %in% rows)
    return(parser_output)
    
  funcs <- d[rows,"text"]

  # make links for functions and not for non-package functions
  paths <- function_help_path(funcs, source_link)  
  text <- str_c("<a href='", router_url(), paths, "'>", funcs,"</a>")
  text[is.na(paths)] <- funcs[is.na(paths)]
  
  # return data
  d[rows,"text"] <- text

#  d[d[,"token.desc"] == "SYMBOL_FUNCTION_CALL","text"] <- text
  attr(parser_output, "data") <- d

  parser_output  
}

