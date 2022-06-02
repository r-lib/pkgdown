# anchor html added to headings

    <h1 id="x">abc<a class="anchor" aria-label="anchor" href="#x"/></h1>

# can process footnote with code

    Code
      xpath_attr(html, ".//a", "data-bs-content")
    Output
      [1] "<p>Including code:</p>\n<pre><code>1 +\n2 +</code></pre>\n<p>And more text</p>"

