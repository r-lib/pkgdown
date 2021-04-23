# build_redirect() works

    Code
      cat(read_lines(file.path(pkg$dst_path, "old.html")))
    Output
      <html>   <head>     <meta http-equiv="refresh" content="0;URL=https://example.com/new.html#section" />     <meta name="robots" content="noindex">     <link rel="canonical" href="https://example.com/new.html#section">   </head> </html> 

