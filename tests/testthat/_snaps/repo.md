# repo_source() truncates automatically

    Code
      cat(repo_source(pkg, character()))
      cat(repo_source(pkg, "a"))
    Output
      Source: <a href='https://github.com/r-lib/pkgdown/blob/HEAD/a'><code>a</code></a>
    Code
      cat(repo_source(pkg, letters[1:10]))
    Output
      Source: <a href='https://github.com/r-lib/pkgdown/blob/HEAD/a'><code>a</code></a>, <a href='https://github.com/r-lib/pkgdown/blob/HEAD/b'><code>b</code></a>, <a href='https://github.com/r-lib/pkgdown/blob/HEAD/c'><code>c</code></a>, and 7 more

