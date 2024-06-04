# highlight_examples runs and hides DONTSHOW calls()

    Code
      cat(strip_html_tags(out))
    Output
      x
      #&gt; [1] 1

# pre() can produce needed range of outputs

    Code
      cat(pre("x"))
    Output
      <pre><code>x</code></pre>
    Code
      cat(pre("x", r_code = TRUE))
    Output
      <pre class='sourceCode r'><code>x</code></pre>

# tweak_highlight_other() renders nested code blocks for roxygen2 >= 7.2.0

    Code
      cat(xpath_text(div, "pre/code"))
    Output
      
      blablabla
      
      ```{r results='asis'}
      lalala
      ```

