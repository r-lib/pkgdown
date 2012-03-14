#' Replay a list of evaluated results, just like you'd run them in a R
#' terminal.
#'
#' @param x result from \code{\link{evaluate}}
#' @param pic_base_name base path for graphics
to_html <- function(x, pic_base_name) UseMethod("to_html", x)

to_html.list <- function(x, pic_base_name) {
  lapply(seq_along(x), function(i, base_name = pic_base_name) {
    item <- x[[i]]
    item_name <- str_c(base_name, "_", i, collapse = "")
    to_html(item, item_name)
  })
}

to_html.character <- function(x, pic_base_name) {
  eval_tag_output(x)
}

to_html.source <- function(x, pic_base_name) {
  if (str_trim(x$src) == "") return(x$src)

  parsed <- parser(text = x$src)
  highlight(parsed)
}

to_html.warning <- function(x, pic_base_name) {
  str_c("<strong>Warning message:\n", x$message, "</strong>", collapse = "")
}

to_html.message <- function(x, pic_base_name) {
  str_c("<strong>", gsub("\n$", "", x$message), "</strong>")
}

to_html.error <- function(x, pic_base_name) {
  if (is.null(x$call)) {
    str_c("<strong>Error: ", x$message, "</strong>", collapse = "\n")
  } else {
    call <- deparse(x$call)
    strong(str_c("Error in ", call, ": ", x$message, collapse = "\n"))    
  }
}

to_html.value <- function(x, pic_base_name) {
  if (!x$visible) return()
  
  eval_tag_output(str_c(capture.output(print(x$value)), collapse = "\n"))
}

to_html.recordedplot <- function(x, pic_base_name) {  
  file_loc <- save_picture(pic_base_name, x)
  str_c("<img class=\"R_output_image\" src=\"", file_loc, "\" alt=\"", pic_base_name, "\" />", collapse = "")
}

#' Evaluate text and return the corresponding text output and source.
#'
#' @param txt text to be evaluated
#' @param pic_base_name base name for the picture files
evaluate_text <- function(txt, pic_base_name) {
  if (!has_text(txt)) return("")

  evaluated <- eval_on_global(txt)
  replayed <- to_html(evaluated, pic_base_name)
  str_c(as.character(unlist(replayed)), collapse = "\n")
}

#' Tag the output text with correct css class
#' 
eval_tag_output <- function(x) {
  str_c("<pre class=\"R_output\">", x, "</pre>")
}


#' Save a picture into the temp directory.
#'
#' @return the path to the picture (using the website)
#' @author Barret Schloerke \email{schloerke@@gmail.com}
#' @keywords internal 
save_picture <- function(obj_name, obj_plot) {
  file_path <- file.path(tempdir(), str_c(obj_name, ".png", collapse = ""))
  
  # only make the picture if you have to
  # duplicates do not exist as naming should be done well
  if(!file.exists(file_path)) { 
    png(file_path)
    on.exit(dev.off())
    print(obj_plot)
  }
  
  str_c("/picture/", obj_name, ".png", collapse = "")
}
