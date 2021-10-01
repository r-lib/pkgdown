# anchors don't get additional newline

    <div class="contents">
      <div id="x">
        <h1>abc</h1>
      </div>
    </div>

# tweak_404() make URLs absolute

    Code
      cat(as.character(xml2::xml_child(prod_html)))
    Output
      <body><div><div><div>
          <a href="https://example.com/reference.html"></a>
          <link href="https://example.com/reference.css">
      <script src="https://example.com/reference.js"></script><img src="https://example.com/" class="pkg-logo">
      </div></div></div></body>

---

    Code
      cat(as.character(xml2::xml_child(dev_html)))
    Output
      <body><div><div><div>
          <a href="https://example.com/reference.html"></a>
          <link href="https://example.com/reference.css">
      <script src="https://example.com/reference.js"></script><img src="https://example.com/" class="pkg-logo">
      </div></div></div></body>

