# usage escapes special characters

    Code
      # Parseable
      cat(strip_html_tags(usage2html("# <>\nx")))
    Output
      # &lt;&gt;
      x
    Code
      # Unparseable
      cat(strip_html_tags(usage2html("# <>\n<")))
    Output
      # &lt;&gt;
      &lt;

