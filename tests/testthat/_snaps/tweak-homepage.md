# can remove logo

    Code
      xpath_xml(html, ".//div")
    Output
      <div class="page-header">
      <img src="mylogo.png" class="logo" alt=""><h1>First </h1>
      </div>

---

    Code
      xpath_xml(html, ".//div")
    Output
      <div class="page-header">
      <img src="mylogo.png" class="logo" alt=""><h1>First </h1>
      </div>

# can move badges to sidebar

    Code
      xpath_xml(html, ".//div")
    Output
      <div class="dev-status">
      <h2 data-toc-skip>Dev status</h2>
      <ul class="list-unstyled">
      <li><a href="x"><img src="y"></a></li>
      </ul>
      </div>

# remove badges even if no dev-status div

    Code
      html
    Output
      {html_document}
      <html>
      [1] <body>\n<h1>Title</h1>\n    </body>

