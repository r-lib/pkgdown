# can get info about external function

    Code
      str(ext_topics("base::mean"))
    Output
      tibble [1 x 11] (S3: tbl_df/tbl/data.frame)
       $ name    : chr "base::mean"
       $ file_in : chr NA
       $ file_out: chr "https://rdrr.io/r/base/mean.html"
       $ alias   :List of 1
        ..$ : chr(0) 
       $ funs    :List of 1
        ..$ : chr "mean()"
       $ title   : chr "Arithmetic Mean (from base)"
       $ rd      :List of 1
        ..$ : chr(0) 
       $ source  : chr NA
       $ keywords:List of 1
        ..$ : chr(0) 
       $ concepts:List of 1
        ..$ : chr(0) 
       $ internal: logi FALSE

# fails if documentation not available

    Code
      ext_topics("base::doesntexist")
    Condition
      Error in `build_reference_index()`:
      ! Could not find documentation for `base::doesntexist()`.

