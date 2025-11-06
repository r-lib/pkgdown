# Test case: output styles

Test case: output styles

## See also

Other tests: [`index`](https://pkgdown.r-lib.org/reference/index.md),
[`test-crayon`](https://pkgdown.r-lib.org/reference/test-crayon.md),
[`test-dont`](https://pkgdown.r-lib.org/reference/test-dont.md),
[`test-figures`](https://pkgdown.r-lib.org/reference/test-figures.md),
[`test-links`](https://pkgdown.r-lib.org/reference/test-links.md),
[`test-lists`](https://pkgdown.r-lib.org/reference/test-lists.md),
[`test-long-lines`](https://pkgdown.r-lib.org/reference/test-long-lines.md),
[`test-math-examples`](https://pkgdown.r-lib.org/reference/test-math-examples.md),
[`test-params`](https://pkgdown.r-lib.org/reference/test-params.md),
[`test-sexpr-title`](https://pkgdown.r-lib.org/reference/test-sexpr-title.md),
[`test-tables`](https://pkgdown.r-lib.org/reference/test-tables.md),
[`test-verbatim`](https://pkgdown.r-lib.org/reference/test-verbatim.md)

## Examples

``` r
# This example illustrates some important output types
# The following output should be wrapped over multiple lines
a <- 1:100
a
#>   [1]   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18
#>  [19]  19  20  21  22  23  24  25  26  27  28  29  30  31  32  33  34  35  36
#>  [37]  37  38  39  40  41  42  43  44  45  46  47  48  49  50  51  52  53  54
#>  [55]  55  56  57  58  59  60  61  62  63  64  65  66  67  68  69  70  71  72
#>  [73]  73  74  75  76  77  78  79  80  81  82  83  84  85  86  87  88  89  90
#>  [91]  91  92  93  94  95  96  97  98  99 100

cat("This some text!\n")
#> This some text!
message("This is a message!")
#> This is a message!
warning("This is a warning!")
#> Warning: This is a warning!

# This is a multi-line block
{
  1 + 2
  2 + 2
}
#> [1] 4
```
