#' @importFrom rjson fromJSON
load_settings <- function(package_path) {
  path <- file.path(package_path, "staticdocs.json")
  if (!file.exists(path)) return(list())

  fromJSON(file = path)
}


#' Define a section for the index page
#'
#'
sd_section <- function(name, description, elements) {
}

#' Define the icon for a function
sd_icon <- function(expr = NULL, func = NULL, inherits = NULL) {
  expr <- substitute(expr)

  if ((is.null(func) + is.null(inherits) + is.null(expr)) != 2) {
    stop("Specify one of expr, func or inherits", call. = FALSE)
  }
  
  if (!is.null(inherits)) {
    return(list(inherits = inherits))
  } else {
    if (!is.null(expr)) {
      func <- make_function(list(), expr)
    }
    list(func = func)
    
  }  
}

make_function <- function(args, expr, env = globalenv()) {
  args <- as.pairlist(args)
  
  f <- eval(call("function", args, expr))
  environment(f) <- env
  f
}