# Accessibility

pkgdown automates as many accessibility details as possible, so that
your package website is readable by as many people as possible. This
vignette describes the additional details that can’t be automated away
and you need to be aware of.

``` r
library(pkgdown)
```

## Theming

- If you adjust any colours from the default theme (including the syntax
  highlighting theme), you should double check that the contrast between
  the background and foreground doesn’t make any text difficult to read.
  A good place to start is running a representative page of your site
  through <https://wave.webaim.org>.

- The default colour of the development version label makes a slightly
  too low contrast against the pale grey background of the navbar. This
  colour comes from the bootstrap “danger” colour, so you can fix it by
  overriding that variable in your `_pkgdown.yml`:

  ``` yaml
  template:
    bootstrap: 5
    bslib:
      danger: "#A6081A"
  ```

- If you use custom navbar entries that only display an icon, make sure
  to also use the `aria-label` field to provide an accessible label that
  describes the icon.

  ``` yaml
  cran:
    icon: fab fa-r-project
    href: https://cloud.r-project.org/package=pkgdown
    aria-label: View on CRAN
  ```

## Images

To make your site fully accessible, the place where you are likely to
need to do the most work is adding alternative text to any images that
you create. Unfortunately, there’s currently no way to do this for plots
you generate in examples, but you can and should add alternative text to
plots in vignettes using the `fig.alt` chunk option:

```` default
```{r}
#| fig.alt: >
#|   Histogram of time between eruptions for Old Faithful. 
#|   It is a bimodal distribution with peaks at 50-55 and 
#|   80-90 minutes.
hist(faithful$waiting)
```
````

If you forget to add alt text to your vignettes, pkgdown will
automatically remind you.
