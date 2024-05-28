# check integrity validates integrity

    Code
      check_integrity(temp, "sha123-abc")
    Condition
      Error in `check_integrity()`:
      ! integrity must use SHA-256, SHA-384, or SHA-512
      i This is an internal error that was detected in the pkgdown package.
        Please report it at <https://github.com/r-lib/pkgdown/issues> with a reprex (<https://tidyverse.org/help/>) and the full backtrace.
    Code
      check_integrity(temp, "sha256-abc")
    Condition
      Error in `check_integrity()`:
      ! Downloaded asset does not match known integrity
      i This is an internal error that was detected in the pkgdown package.
        Please report it at <https://github.com/r-lib/pkgdown/issues> with a reprex (<https://tidyverse.org/help/>) and the full backtrace.

