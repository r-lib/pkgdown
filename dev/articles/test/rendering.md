# Output Rendering

This vignette tests pkgdown output rendering for several use cases.

## Footnotes

Yay[¹](#fn1)

## Figures

``` r
plot(1:10)
```

![Test plot](rendering_files/figure-html/unnamed-chunk-2-1.png)

## External files

``` r
x <- readLines("test.txt")
x
#> [1] "a" "b" "c" "d"
```

![bacon](bacon.jpg)

bacon

## Details tag

This should only be shown when required

Multiple paragraphs

First paragraph

Second paragraph

Some R code

``` r
1 + 2
#> [1] 3
```

## Tables

| col 1      | col 2                                                   |    col 3    | col 4 |
|:-----------|:--------------------------------------------------------|:-----------:|:-----:|
| Brightness | Total brightness, total reflectance, spectral intensity | \\y = x^2\\ | test  |

## Math

\\f(x) = \dfrac{1}{\sqrt{2\pi\sigma^2}}
e^{-\frac{(x-\mu^2)}{2\sigma^2}}\\

Inline equations: \\y=x^2\\

## Code

### Line width

``` r
pkgdown:::ruler()
#> ----+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
#> 12345678901234567890123456789012345678901234567890123456789012345678901234567890

cat(rep("x ", 100), sep = "")
#> x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x
cat(rep("xy", 100), sep = "")
#> xyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxy
```

### Should be highlighted

Valid R code in `\preformatted{}`:

    mean(a + 1)

R code in `R` block:

``` r
mean(a + 1)
```

R code in `r` block:

``` r
mean(a + 1)
```

Yaml

``` yaml
yaml: [a, 1]
```

### Shouldn’t be highlighted

Non-R code in `\preformatted{}`

    yaml: [a, b, c]

### Crayon

``` r
cat(cli::col_red("This is red"), "\n")
#> This is red
cat(cli::col_blue("This is blue\n"), "\n")
#> This is blue
#> 

message(cli::col_green("This is green"))
#> This is green

warning(cli::style_bold("This is bold"))
#> Warning: This is bold
```

Some text

``` r
stop(cli::style_italic("This is italic"))
#> Error:
#> ! This is italic
```

Some more text

## Quoted text

> Single-line quote about something miscellaneous.

Flush  
 1 space indent  
  2 space indent  
   3 space indent

## This section is unnumbered

There should however be no bug here!

## Tabsets

### Tabset with pills

- Tab 1
- Tab 2

blablablabla

``` r
1 + 1
```

Should be “cool” heading below

##### cool

Stuff

blop

### Tabset without pills

- Tab 1
- Tab 2

something nice

``` r
plot(1:42)
```

![Another test plot](rendering_files/figure-html/unnamed-chunk-8-1.png)

This tab should be active

### Fading tabset

- English
- French
- German

Hello!

Bonjour!

Guten tag.

## Deep headings

### Heading 3

#### Heading 4

##### Heading 5

## Very long words

This word should be broken across multiple lines on mobile, rather than
making the page scroll horizontally:

Ccccccccccccaaaaaaaaaaaaaaatttttttttttttttttssssssssssssssss

------------------------------------------------------------------------

1.  Including **footnotes**! 😁
