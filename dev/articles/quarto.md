# quarto vignettes

pkgdown effectively uses quarto only to generate HTML and then supplies
its own CSS and JS. This means that when quarto introduces new features,
pkgdown may lag behind in their support. If you’re trying out something
that doesn’t work (and isn’t mentioned explicitly below), please [file
an issue](https://github.com/r-lib/pkgdown/issues) so we can look into
it.

## Operation

pkgdown turns your articles directory into a quarto project by
temporarily adding a `_quarto.yml` to your articles. You can also add
your own if you want to control options for all quarto articles. If you
do so, and you have a mix of `.qmd` and `.Rmd` files, you’ll need to
include the following yaml so that RMarkdown can continue to handle the
.Rmd files:

``` yaml
project:
  render: ['*.qmd']
```

### GitHub Actions

The `setup-r-dependencies` action will
[automatically](https://github.com/r-lib/actions/tree/v2-branch/setup-r-dependencies#usage)
install Quarto in your GitHub Actions if a .qmd file is present in your
repository (see the `install-quarto` parameter for more details).

## Limitations

- Callouts are not currently supported
  (<https://github.com/quarto-dev/quarto-cli/issues/9963>).

- pkgdown assumes that you’re using [quarto vignette
  style](https://quarto-dev.github.io/quarto-r/articles/hello.html), or
  more generally an html format with
  [`minimal: true`](https://quarto.org/docs/output-formats/html-basics.html#minimal-html).
  Specifically, only HTML vignettes are currently supported.

- You can’t customise mermaid styles with quarto mermaid themes. If you
  want to change the colours, you’ll need to provide your own custom CSS
  as shown in [the quarto
  docs](https://quarto.org/docs/authoring/diagrams.html#customizing-mermaid).

- pkgdown will pass the `lang` setting on to quarto, but the set of
  available languages is not perfectly matched. Learn more in
  <https://quarto.org/docs/authoring/language.html>, including how to
  supply your own translations.

## Supported features

The following sections demonstrate a bunch of useful quarto features so
that we can make sure that they work.

### Inline formatting

- SMALL CAPS

- Here is a footnote reference[¹](#fn1)

### Code

``` r
1 + 1
#> [1] 2
2 + 2
#> [1] 4

plot(1:3)
```

![A plot of the numbers 1, 2, and
3](quarto_files/figure-html/unnamed-chunk-1-1.png)

### Figures

![](pitbull.jpg)

\(a\) A sketch of a pitbull puppy

![](shar-pei.jpg)

\(b\) A sketch of a sharpei puppy

Figure 1: Cute puppies

### Equations

\\ \frac{\partial \mathrm C}{ \partial \mathrm t } +
\frac{1}{2}\sigma^{2} \mathrm S^{2} \frac{\partial^{2} \mathrm
C}{\partial \mathrm C^2} + \mathrm r \mathrm S \frac{\partial \mathrm
C}{\partial \mathrm S}\\ = \mathrm r \mathrm C \tag{1}\\

### Cross references

See [Figure 1](#fig-puppies) for two cute puppies.

Black-Scholes ([Equation 1](#eq-black-scholes)) is a mathematical model
that seeks to explain the behavior of financial derivatives, most
commonly options.

## To do

Code annotations

Tabsets

Citations

Task/to do lists

Figures

Equations

Cross-references

Footnotes

Callouts

------------------------------------------------------------------------

1.  And here is the footnote.
