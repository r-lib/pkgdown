\name{render_template}
\alias{render_template}
\title{Render template.}
\usage{
  render_template(name, data, path = "")
}
\arguments{
  \item{name}{of the template}

  \item{data}{data for the template}

  \item{path}{location to create file.  If \code{""} (the
  default), prints to standard out.}
}
\description{
  Render template.
}
\examples{
rd <- parse_rd("colSums", "base")
html <- to_html(rd, package = "base")
render_template("topic", html)
}

