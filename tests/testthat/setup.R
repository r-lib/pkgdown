# suppress cli messages in interactive testthat output
# https://github.com/r-lib/cli/issues/434
options(cli.default_handler = function(...) { })
