\name{to_html}
\alias{to_html}
\title{Convert an rdoc to a list of html components.}
\usage{
  to_html(x, ...)
}
\arguments{
  \item{x}{rd object to convert to html}

  \item{...}{other arguments passed onto to methods}
}
\value{
  A list, suitable for rendering with
  \code{\link[whisker]{whisker.render}}
}
\description{
  All span-level tags are converted to html, and higher
  level blocks are returned as components of the list.
}

