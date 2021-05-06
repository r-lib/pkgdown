# pre() can produce needed range of outputs

    Code
      cat(pre("x"))
    Output
      <pre>x</pre>
    Code
      cat(pre("x", r_code = TRUE))
    Output
      <pre><code class='sourceCode R'>x</code></pre>
    Code
      cat(pre("x", class = "test"))
    Output
      <pre class='test'>x</pre>
    Code
      cat(pre("x", r_code = TRUE, class = "test"))
    Output
      <pre class='test'><code class='sourceCode R'>x</code></pre>

