data_reference_index <- function(pkg = ".", depth = 1L) {
  pkg <- as_pkgdown(pkg)

  meta <- pkg$meta[["reference"]] %||% default_reference_index(pkg)
  if (length(meta) == 0) {
    return(list())
  }
  
  sections <- list()
  
  # Write S4 documentation if available
  if(!is.null(pkg$meta[["reference"]])){
	  s4_documentation <- 
			  pkg$meta[["reference"]] %>% purrr::map(.$title) %>% 
			  unlist() %>% grepl(pattern="S4") %>% which()
	  
	  if(length(s4_documentation)>0){
		  sections <- data_reference_index_S4(pkg)
		  
		  meta[[s4_documentation]] <- NULL
	  }
  }
  sections <- append(sections, meta %>%
    purrr::map(data_reference_index_section, pkg = pkg, depth = depth) %>%
    purrr::compact())

  # Cross-reference complete list of topics vs. topics found in index page
  all_topics <- meta %>%
    purrr::map(~ select_topics(.$contents, pkg$topics)) %>%
    purrr::reduce(union)
  in_index <- seq_along(pkg$topics$name) %in% all_topics

  missing <- !in_index & !pkg$topics$internal
  if (any(missing)) {
    warning(
      "Topics missing from index: ",
      paste(pkg$topics$name[missing], collapse = ", "),
      call. =  FALSE,
      immediate. = TRUE
    )
  }

  print_yaml(list(
    pagetitle = "Function reference",
    sections = sections
  ))
}

data_reference_index_section <- function(section, pkg, depth = 1L) {
  if (!set_contains(names(section), c("title", "contents"))) {
    warning(
      "Section must have components `title`, `contents`",
      call. = FALSE,
      immediate. = TRUE
    )
    return(NULL)
  }

  # Find topics in this section
  in_section <- select_topics(section$contents, pkg$topics)
  section_topics <- pkg$topics[in_section, ]

  contents <- tibble::tibble(
    path = section_topics$file_out,
    aliases = purrr::map2(
      section_topics$funs,
      section_topics$name,
      ~ if (length(.x) > 0) .x else .y
    ),
    title = section_topics$title,
    icon = find_icons(section_topics$alias, file.path(pkg$path, "icons"))
  )
  list(
    title = section$title,
    slug = paste0("section-", make_slug(section$title)),
    desc = markdown_text(section$desc, depth = depth),
    class = section$class,
    contents = purrr::transpose(contents)
  )
}


find_icons <- function(x, path) {
  purrr::map(x, find_icon, path = path)
}
find_icon <- function(aliases, path) {
  names <- paste0(aliases, ".png")
  exists <- file.exists(file.path(path, names))

  if (!any(exists)) {
    NULL
  } else {
    names[which(exists)[1]]
  }
}

default_reference_index <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  exported <- pkg$topics[!pkg$topics$internal, , drop = FALSE]
  if (nrow(exported) == 0) {
    return(list())
  }

  print_yaml(list(
    list(
      title = "All functions",
      desc = NULL,
      contents = paste0('`', exported$name, '`')
    )
  ))
}
#' Function to build references for S4 classes
data_reference_index_S4 <- function(pkg="."){
	pkg <- as_pkgdown(pkg)
	
	# Derive exported topics
	exported <- pkg$topics[!pkg$topics$internal, , drop = FALSE]
	if (nrow(exported) == 0) {
		return(list())
	}
	
	# Derive classes and method rows out of topics
	classes_index <- which(grepl("class",exported$name))
	methods_index <- which(grepl("method",exported$alias))
	
	# Create an empty list of section
	
	list_of_sections <- list()
	
	# For each class append all methods as reference link
	for(class_index in classes_index){
		
		title <- gsub("-class","",exported$name[class_index])
		
		methods_index_index <- which(title==gsub("\")","",
						gsub(".*,","",gsub("-method","",exported$alias[methods_index]))
				))
		
		if(length(methods_index_index)>0){
			class_methods <- exported[c(class_index,methods_index[methods_index_index]),]
		}else{
			class_methods <- exported[c(class_index),]
		}
		list_of_sections <- append(list_of_sections,list(
						list(
								title=title,
								desc= paste0("Class with name ",title),
								slug = paste0("section-", make_slug(title)),
								contents = purrr::transpose(tibble::tibble(
										path = class_methods$file_out,
										aliases = purrr::map2(
												class_methods$funs,
												class_methods$name,
												~ if (length(.x) > 0) .x else .y
										),
										title = class_methods$title,
										icon = find_icons(class_methods$alias, file.path(pkg$path, "icons"))
								))
						))
		)#append
	}
	
	return(list_of_sections)
}
