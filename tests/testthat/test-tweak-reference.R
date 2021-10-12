test_that("tweak_reference_topic_html() works", {
  html_skeleton <- "<body>
  <div class='ref-section'>
  %s
  </div>
  </body>"
  build_html <- function(html_skeleton, block) {
    html <- xml2::read_html(sprintf(html_skeleton, block))
    xml2::xml_child(html)
  }

  r_block <- '<div class="sourceCode r">
  <pre>
  <code>
  rlang::is_installed()\n
  </code>
  </pre>
  </div>'
  expect_snapshot_output(
    cat(
      as.character(
        tweak_reference_topic_html(build_html(html_skeleton, r_block))
      )
    )
  )

  no_info_r_block <- '<pre>
  <code>
  rlang::is_installed()\n
  </code>
  </pre>'
  expect_snapshot_output(
    cat(
      as.character(
        tweak_reference_topic_html(build_html(html_skeleton, no_info_r_block))
      )
    )
  )

  yaml_block <- '<div class="sourceCode yaml">
  <pre>
  <code>
  url: https://pkgdown.r-lib.org/\n
  </code>
  </pre>
  </div>'
  expect_snapshot_output(
    cat(
      as.character(
        tweak_reference_topic_html(build_html(html_skeleton, yaml_block))
      )
    )
  )
})
