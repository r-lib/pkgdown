# portalr

<details>

* Version: 0.3.9
* GitHub: https://github.com/weecology/portalr
* Source code: https://github.com/cran/portalr
* Date/Publication: 2021-12-03 05:20:02 UTC
* Number of recursive dependencies: 106

Run `cloud_details(, "portalr")` for more info

</details>

## Newly broken

*   checking tests ... ERROR
    ```
      Running ‘testthat.R’
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
       5. ├─base::as.data.frame(.)
       6. ├─tidyr::complete(., !!!grouping, fill = list(presence = 0))
       7. ├─dplyr::mutate(., presence = 1)
       8. ├─dplyr::distinct(.)
       9. └─dplyr::select(., !!!grouping)
      ── Error (test-11-phenocam.R:6:1): (code run outside of `test_that()`) ─────────
      Error in `-nrow(moon_dates)`: invalid argument to unary operator
      Backtrace:
          ▆
       1. └─portalr::phenocam("newmoon", path = portal_data_path) at test-11-phenocam.R:6:0
       2.   └─base::as.Date(moon_dates$newmoondate[-nrow(moon_dates)])
      
      [ FAIL 13 | WARN 43 | SKIP 41 | PASS 13 ]
      Error: Test failures
      Execution halted
    ```

