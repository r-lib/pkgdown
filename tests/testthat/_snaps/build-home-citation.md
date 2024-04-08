# source link is added to citation page

    Code
      build_home(pkg)
    Message
      Writing `authors.html`
      Writing `404.html`

# multiple citations all have HTML and BibTeX formats

    [[1]]
    [[1]]$html
    [1] "<p>A &amp; B (2021): Proof of b &lt; a &gt; c.</p>"
    
    [[1]]$bibtex
    [1] "@Misc{,\n  title = {Proof of b < a > c},\n  author = {{A} and {B}},\n  year = {2021},\n}"
    
    
    [[2]]
    [[2]]$html
    [1] "<p>Two A (2022).\n&ldquo;Title Two.&rdquo; \n</p>"
    
    [[2]]$bibtex
    [1] "@Misc{,\n  title = {Title Two},\n  author = {Author Two},\n  year = {2022},\n}"
    
    

