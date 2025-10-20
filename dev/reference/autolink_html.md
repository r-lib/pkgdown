# Automatically link references and articles in an HTML page

**\[deprecated\]**

Please use
[`downlit::downlit_html_path()`](https://downlit.r-lib.org/reference/downlit_html_path.html)
instead.

## Usage

``` r
autolink_html(input, output = input, local_packages = character())
```

## Arguments

- input, output:

  Input and output paths for HTML file

- local_packages:

  A named character vector providing relative paths (value) to packages
  (name) that can be reached with relative links from the target HTML
  document.

## Examples

``` r
if (FALSE) { # \dontrun{
autolink_html("path/to/file.html",
  local_packages = c(
    shiny = "shiny",
    shinydashboard = "shinydashboard"
  )
)
} # }
```
