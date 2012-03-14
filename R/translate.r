#' Parse help file.
#' Function to turn a help topic into a convenient format.
#'
#' @param rd item to be tagged recursively
#' @return item reformatted to be used in HTML
#' @author Hadley Wickham and Barret Schloerke \email{schloerke@@gmail.com}
#' @keywords internal
parse_help <- function(rd, package) {
  tags <- sapply(rd, tag)

  # Remove top-level text strings - just line breaks between sections
  rd <- rd[tags != "TEXT"]

  out <- list()
  
  # Join together aliases and keywords
  out$name <- to_html(untag(rd$name), package)
  out$aliases <- setdiff(
    unname(sapply(rd[names(rd) == "alias"], "[[", 1)),
    out$name
  )
  out$keywords <- unname(sapply(rd[names(rd) == "keyword"], "[[", 1))

  # Title, description, value and examples, need to be stitched into a 
  # single string.
  out$title <- to_html(untag(rd$title), package)
  out$desc <- gsub("$\n+|\n+^", "", to_html(rd$description, package))
  out$details <- to_html(rd$details, package)
  out$value <- to_html(rd$value, package)
  reconstructed_examples <- to_html(untag(rd$examples), package)
  par_text <- parse_text(reconstructed_examples)
  out$examples <- highlight(par_text)
  out$usage <- parse_usage(rd$usage, package)
  out$authors <- pkg_author_and_maintainers(to_html(rd$author, package))
  out$author_str <- pluralize("Author", rd$author)

  out$seealso <- to_html(rd$seealso, package)
  out$source <- to_html(untag(rd$source), package)

  sectionPos <- names(tags) %in% "section"
  out$sections <- str_c(sapply(rd[sectionPos], function(x){
    to_html(x, package = package)
  }), collapse = "<br />")
  

  # Pull apart arguments
  arguments <- rd$arguments
#  arguments <- arguments[! sapply(arguments, tag) %in% c("TEXT", "COMMENT")]
  argument_tags <- sapply(arguments, tag)
  args <- lapply(arguments[argument_tags == "\\item"], function(argument) {
    list(
      param = to_html(untag(argument[[1]]), package), 
      desc = to_html(untag(argument[[2]]), package)
    )
  })
  
  pre_text <- to_html(arguments[ seq_len( first_item_pos( argument_tags) - 1)], package)
  
  post_text <- to_html(
    arguments[seq(
      from = last_item_pos(argument_tags)+1, 
      length.out = length(arguments) - last_item_pos(argument_tags)
    )],
  package
  )

  out$params <- list(
    args = args,
    pre_text = pre_text,
    post_text = post_text
  )

  out
}