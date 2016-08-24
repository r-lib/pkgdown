# staticdocs

[![Build Status](https://travis-ci.org/hadley/staticdocs.png?branch=master)](https://travis-ci.org/hadley/staticdocs)

staticdocs provides a way to conveniently render R package documentation into html pages suitable for stand-alone viewing, such as on a package webpage. You can see staticdocs in action at <http://staticdocs.had.co.nz>: this is the output of staticdocs applied to the latest version of staticdocs.

staticdocs is not currently available from CRAN, but you can install the development version from github with:

```R
# install.packages("devtools")
devtools::install_github("hadley/staticdocs")
```

# Features

* Attractive defaults: staticdocs uses [bootstrap]
  (https://getbootstrap.com/2.0.4/) to provide an attractive website.

* Customisable: you can override the default templates to provide
  alternative rendering

* Flexible ways to specify the index page so you can group related
  functions together.

Compared to `Rd2html`, staticdocs:

* Makes it easier to customise the output.

* Runs examples, so users see both input and output.

* Assumes only one package is being rendered - links to documentation in
  other packages are forwarded to [Rdocumentation](http://www.rdocumentation.org/).
