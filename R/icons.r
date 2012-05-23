#' @importFrom grid grid.draw
render_icons <- function(package) {
  icon_path <- file.path(package$base_path, "icons")  
  if (!file.exists(icon_path)) dir.create(icon_path)

  icons <- package$icons
  
  has_icon <- Filter(function(x) !is.null(x$func), icons)
  
  for(icon in names(has_icon)) {
    png(file.path(icon_path, icon_name(icon)), width = 40, height = 40)
    try(grid.draw(icons[[icon]]$func()))
    dev.off()
  }
}

icon_path <- function(package, topic) {
  icon <- package$icons[[topic]]
  if (is.null(icon)) return(NULL)

  if (!is.null(icon$func)) {
    return(file.path("icons", icon_name(topic)))
  }
  if (!is.null(icon$inherits)) {
    return(file.path("icons", icon_name(icon$inherits)))
  }
  
  NULL
}

icon_name <- function(topic) paste(topic, ".png", sep = "")