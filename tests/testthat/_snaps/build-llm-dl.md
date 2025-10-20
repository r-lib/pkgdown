# dd with block elements simplifies correctly

    Code
      xpath_xml(html, ".//li")
    Output
      <li>
      <p>a: </p>
                <p>b</p>
                <p>c</p>
              </li>

# warns if not applied

    Code
      . <- simplify_dls(html)
    Condition
      Warning:
      Skipping this <dl>: not a simple term-definition list

