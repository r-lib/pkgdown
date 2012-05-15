\name{build_vignettes}
\alias{build_vignettes}
\title{List all package vignettes.}
\usage{
  build_vignettes(package)
}
\arguments{
  \item{package}{path to source version of package.  See
  \code{\link[devtools]{as.package}} for details on how
  paths and package names are resolved.}
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

