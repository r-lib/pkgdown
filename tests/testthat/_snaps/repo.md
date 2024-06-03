# repo_source() truncates automatically

    Code
      cat(repo_source(pkg, character()))
      cat(repo_source(pkg, "a"))
    Output
      Source: <a href='https://github.com/r-lib/pkgdown/blob/main/a'><code>a</code></a>
    Code
      cat(repo_source(pkg, letters[1:10]))
    Output
      Source: <a href='https://github.com/r-lib/pkgdown/blob/main/a'><code>a</code></a>, <a href='https://github.com/r-lib/pkgdown/blob/main/b'><code>b</code></a>, <a href='https://github.com/r-lib/pkgdown/blob/main/c'><code>c</code></a>, and 7 more

