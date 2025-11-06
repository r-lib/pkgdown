# quarto features

## Citations

- Citation: Wickham ([2014](#ref-JSSv059i10))

## Code annotations

``` r
library(tidyverse)
library(palmerpenguins)
1penguins |>
2  mutate(
    bill_ratio = bill_depth_mm / bill_length_mm,
    bill_area  = bill_depth_mm * bill_length_mm
  )
```

- 1:

  Take `penguins`, and then,

- 2:

  add new columns for the bill ratio and bill area.

## Diagrams

``` mermaid
flowchart LR
  A[Hard edge] --> B(Round edge)
  B --> C{Decision}
  C --> D[Result one]
  C --> E[Result two]
```

## HTML widgets

## Keyboard

- Keyboard shortcut: Shift-Ctrl-PShift-Ctrl-P

## References

Wickham, Hadley. 2014. “Tidy Data.” *Journal of Statistical Software,
Articles* 59 (10): 1–23. <https://doi.org/10.18637/jss.v059.i10>.
