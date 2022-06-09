# can get info about external function

    Code
      str(ext_topics("base::mean"))
    Output
      tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
       $ name    : chr "base::mean"
       $ file_out: chr "https://rdrr.io/r/base/mean.html"
       $ title   : chr "Arithmetic Mean (from base)"
       $ funs    :List of 1
        ..$ : chr "mean()"
       $ alias   :List of 1
        ..$ : chr(0) 
       $ internal: logi FALSE

# fails if documentation not available

    Code
      ext_topics("base::doesntexist")
    Condition
      Error in `.f()`:
      ! Could not find documentation for base::doesntexist

