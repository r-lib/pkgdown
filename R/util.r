inst_path <- function(..., package=NULL) {
	
	path <-	
	if( is.null(package) ){ # return inst path from staticdocs
		envname <- environmentName(environment(inst_path))
		
		if (envname == "staticdocs") {
			# Probably in package
			system.file(package = "staticdocs")
		} else {
			# Probably in development
			srcref <- attr(find_template, "srcref")
			path <- dirname(dirname(attr(srcref, "srcfile")$filename))
			file.path(path, "inst")
		}
	}else{ # return inst directory from package object
		package <- package_info(package)
		
		path <- package$path
		metadir <- file.path(path, 'Meta')
		if( file_test('-d', metadir) ){ # installed package
			path 
		}else{ # development package: append 'inst' to path
			file.path(path, 'inst') 
		}
		
	}
	# add extra path
	file.path(path, ...)
}

"%||%" <- function(a, b) {
  if (!is.null(a)) a else b
}

rows_list <- function(df) {
  lapply(seq_len(nrow(df)), function(i) as.list(df[i, ]))
}

#' @importFrom markdown markdownToHTML
markdown <- function(x = NULL, path = NULL) {
  if (is.null(path)) {
    if (is.null(x) || x == "") return("")
  }
  
  (markdownToHTML(text = x, file = path,
    options = c("safelink", "use_xhtml", "smartypants")))
}