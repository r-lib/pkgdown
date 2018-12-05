# conflicted

Version: 1.0.1

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘memoise’
      All declared Imports should be used.
    ```

# eplusr

Version: 0.9.4

## Newly broken

*   checking examples ... ERROR
    ```
    ...
    > 
    > ### ** Examples
    > 
    > # get the Idd object of EnergyPlus v8.8
    > idd <- use_idd(8.8, download = "auto")
    Idd v8.8.0 has not been parsed before. Try to locate `Energy+.idd` in EnergyPlus v8.8.0 installation folder `/Applications/EnergyPlus-8-8-0`.
    Failed to locate `Energy+.idd` because EnergyPlus v8.8.0 is not available. 
    Starting to download the IDD file from EnergyPlus GitHub repo...
    trying URL 'https://raw.githubusercontent.com/NREL/EnergyPlus/v9.0.0/idd/V8-8-0-Energy%2B.idd'
    Content type 'text/plain; charset=utf-8' length 4055399 bytes (3.9 MB)
    =============================
    downloaded 2.3 MB
    
    Warning in utils::download.file(url, dest, mode = "wb") :
      downloaded length 2391222 != reported length 4055399
    Warning in utils::download.file(url, dest, mode = "wb") :
      URL 'https://raw.githubusercontent.com/NREL/EnergyPlus/v9.0.0/idd/V8-8-0-Energy%2B.idd': status was 'Failure when receiving data from the peer'
    Error in utils::download.file(url, dest, mode = "wb") : 
      download from 'https://raw.githubusercontent.com/NREL/EnergyPlus/v9.0.0/idd/V8-8-0-Energy%2B.idd' failed
    Calls: use_idd -> download_idd -> download_file -> <Anonymous>
    Execution halted
    ```

## In both

*   checking re-building of vignette outputs ... WARNING
    ```
    Error in re-building vignettes:
      ...
    trying URL 'https://github.com/NREL/EnergyPlus/releases/download/v8.8.0/EnergyPlus-8.8.0-7c3bbe4830-Darwin-x86_64.tar.gz'
    Content type 'application/octet-stream' length 107833618 bytes (102.8 MB)
    =======
    downloaded 16.1 MB
    
    Quitting from lines 84-103 (eplusr.Rmd) 
    Error: processing vignette 'eplusr.Rmd' failed with diagnostics:
    download from 'https://github.com/NREL/EnergyPlus/releases/download/v8.8.0/EnergyPlus-8.8.0-7c3bbe4830-Darwin-x86_64.tar.gz' failed
    Execution halted
    ```

# FSA

Version: 0.8.22

## In both

*   checking Rd cross-references ... NOTE
    ```
    Packages unavailable to check Rd xrefs: ‘alr4’, ‘prettyR’, ‘RMark’, ‘PMCMR’, ‘pgirmess’, ‘agricolae’
    ```

# FSelectorRcpp

Version: 0.3.0

## In both

*   checking whether package ‘FSelectorRcpp’ can be installed ... ERROR
    ```
    Installation failed.
    See ‘/Users/hadley/Documents/devtools/pkgdown/revdep/checks.noindex/FSelectorRcpp/new/FSelectorRcpp.Rcheck/00install.out’ for details.
    ```

## Installation

### Devel

```
* installing *source* package ‘FSelectorRcpp’ ...
** package ‘FSelectorRcpp’ successfully unpacked and MD5 sums checked
** libs
clang++ -std=gnu++11 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I"/Users/hadley/Documents/devtools/pkgdown/revdep/library.noindex/FSelectorRcpp/Rcpp/include" -I"/Users/hadley/Documents/devtools/pkgdown/revdep/library.noindex/FSelectorRcpp/BH/include" -I"/Users/hadley/Documents/devtools/pkgdown/revdep/library.noindex/FSelectorRcpp/RcppArmadillo/include" -I"/Users/hadley/Documents/devtools/pkgdown/revdep/library.noindex/FSelectorRcpp/testthat/include" -I/usr/local/include  -fopenmp -I../inst/include -fPIC  -Wall -g -O2 -c RcppExports.cpp -o RcppExports.o
clang: error: unsupported option '-fopenmp'
make: *** [RcppExports.o] Error 1
ERROR: compilation failed for package ‘FSelectorRcpp’
* removing ‘/Users/hadley/Documents/devtools/pkgdown/revdep/checks.noindex/FSelectorRcpp/new/FSelectorRcpp.Rcheck/FSelectorRcpp’

```
### CRAN

```
* installing *source* package ‘FSelectorRcpp’ ...
** package ‘FSelectorRcpp’ successfully unpacked and MD5 sums checked
** libs
clang++ -std=gnu++11 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I"/Users/hadley/Documents/devtools/pkgdown/revdep/library.noindex/FSelectorRcpp/Rcpp/include" -I"/Users/hadley/Documents/devtools/pkgdown/revdep/library.noindex/FSelectorRcpp/BH/include" -I"/Users/hadley/Documents/devtools/pkgdown/revdep/library.noindex/FSelectorRcpp/RcppArmadillo/include" -I"/Users/hadley/Documents/devtools/pkgdown/revdep/library.noindex/FSelectorRcpp/testthat/include" -I/usr/local/include  -fopenmp -I../inst/include -fPIC  -Wall -g -O2 -c RcppExports.cpp -o RcppExports.o
clang: error: unsupported option '-fopenmp'
make: *** [RcppExports.o] Error 1
ERROR: compilation failed for package ‘FSelectorRcpp’
* removing ‘/Users/hadley/Documents/devtools/pkgdown/revdep/checks.noindex/FSelectorRcpp/old/FSelectorRcpp.Rcheck/FSelectorRcpp’

```
# linguisticsdown

Version: 1.1.0

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘tidyr’
      All declared Imports should be used.
    ```

# LPWC

Version: 0.99.4

## In both

*   checking package dependencies ... ERROR
    ```
    Package required but not available: ‘devtools’
    
    See section ‘The DESCRIPTION file’ in the ‘Writing R Extensions’
    manual.
    ```

# metR

Version: 0.2.0

## In both

*   checking installed package size ... NOTE
    ```
      installed size is  5.4Mb
      sub-directories of 1Mb or more:
        R      2.0Mb
        data   1.1Mb
        doc    1.5Mb
    ```

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘curl’
      All declared Imports should be used.
    ```

# MTseeker

Version: 1.0.6

## In both

*   checking package dependencies ... ERROR
    ```
    Package required but not available: ‘Homo.sapiens’
    
    Package suggested but not available for checking: ‘MTseekerData’
    
    See section ‘The DESCRIPTION file’ in the ‘Writing R Extensions’
    manual.
    ```

# radiant.data

Version: 0.9.7

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘shinyFiles’
      All declared Imports should be used.
    ```

