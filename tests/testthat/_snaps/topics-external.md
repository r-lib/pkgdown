# can get info about external function

    Code
      str(ext_topics("base::mean"))
    Output
      tibble [0 x 11] (S3: tbl_df/tbl/data.frame)
       $ name    : chr(0) 
       $ file_in : chr(0) 
       $ file_out: chr(0) 
       $ alias   : list()
       $ funs    : list()
       $ title   : chr(0) 
       $ rd      : list()
       $ source  : chr(0) 
       $ keywords: list()
       $ concepts: list()
       $ internal: logi(0) 

# fails if documentation not available

    Code
      ext_topics("base::doesntexist")
    Condition
      Error in `.f()`:
      ! Could not find documentation for base::doesntexist

