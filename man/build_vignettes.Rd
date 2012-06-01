\name{build_vignettes}
\alias{build_vignettes}
\title{List all package vignettes.}
\usage{
  build_vignettes(package)
}
\arguments{
  \item{package}{a character string naming an installed
  package.  If given, Sweave files are searched in
  subdirectory \file{doc}.}
}
\value{
  a list, with one element for each vignette containing the
  vignette title and file name.
}
\description{
  Copies all vignettes and returns data structure suitable
  for use with whisker templates.
}
\keyword{internal}

