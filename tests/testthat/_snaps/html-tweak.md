# anchors don't get additional newline

    <div class="contents">
      <div id="x">
        <h1>abc</h1>
      </div>
    </div>

# page header modification succeeds

    <h1 class="hasAnchor"><a href="#plot" class="anchor"> </a><img src="someimage" alt=""/> some text
        </h1>

# links to vignettes & figures tweaked

    <body>
      <img src="articles/x.png"/>
      <img src="reference/figures/x.png"/>
    </body>

