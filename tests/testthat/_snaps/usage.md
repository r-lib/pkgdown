# usage generates user facing code for S3/S4 infix/replacement methods

    Code
      cat(usage2text("\\S3method{$}{indexed_frame}(x, name)"))
    Output
      # S3 method for class 'indexed_frame'
      x$name
    Code
      cat(usage2text("\\method{[[}{indexed_frame}(x, i) <- value"))
    Output
      # S3 method for class 'indexed_frame'
      x[[i]] &lt;- value
    Code
      cat(usage2text("\\S4method{>=}{MyType,numeric}(e1, e2)"))
    Output
      # S4 method for class 'MyType,numeric'
      e1 &gt;= e2

