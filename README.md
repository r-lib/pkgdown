# staticdocs

`staticdocs` provides a way to conveniently render R package documentation into html pages suitable for stand-alone viewing, such as on a package webpage.  

See the `staticdocs` documentation rendered with `staticdocs` at http://hadley.github.com/staticdocs/

# Features

* Attractive defaults: `staticdocs` uses [bootstrap](http://twitter.github.com/bootstrap/) to provide an attractive website that you can easily customise.

* Customisable: you can override the default templates to provide alternative rendering

Compared to `Rd2html`, staticdoc:

* Makes it easier to customise the output

* Renders examples, so users see both input and output

* Assumes only one package is being rendered - links to documentation in
  other packages are forwarded to the inside-r site.