fig_name <- function(topic, obj_id) {
  paste0(topic, "-", obj_id(topic))
}

fig_save <- function(plot,
                     name,
                     dev = grDevices::png,
                     dpi = 96,
                     dev.args = list(),
                     fig.ext = "png",
                     fig.width = 7.29, # 700 pixels
                     fig.height = NULL,
                     fig.retina = 2,
                     fig.asp = 1.618
                     ) {


  path <- paste0(name, ".", fig.ext)

  if (is.null(fig.height)) {
    fig.height <- fig.width / fig.asp
  }
  width <- round(dpi * fig.width)
  height <- round(dpi * fig.height)

  args <- list(
    path, # some devices use file and some use filename
    width = width * fig.retina,
    height = height * fig.retina
  )
  with_device(dev, c(args, dev.args), plot)

  paste0(
    "<div class='img'>",
    "<img src='", escape_html(path), "' alt='' width='", width, "' height='", height, "' />",
    "</div>"
  )
}

with_device <- function(dev, dev.args, plot) {
  do.call(dev, dev.args)
  on.exit(grDevices::dev.off())

  print(plot)
}
