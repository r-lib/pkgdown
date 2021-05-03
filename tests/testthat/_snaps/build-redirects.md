# build_redirect() works

    Code
      cat(read_lines(file.path(pkg$dst_path, "old.html")))
    Output
      <html>   <head>     <meta http-equiv="refresh" content="0;URL=https://example.com/new.html#section" />     <meta name="robots" content="noindex">     <link rel="canonical" href="https://example.com/new.html#section">   </head> </html> 

# build_redirect() errors if one entry is not right.

    All redirect entries must have length 2 (entry 5 in redirects has length 1).

