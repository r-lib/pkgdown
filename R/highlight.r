# highlight_text mutates the linking scope because it has to register
# library()/require() calls in order to link unqualified symbols to the
# correct package.
highlight_text <- function(text) {
  stopifnot(is.character(text), length(text) == 1)

  expr <- tryCatch(
    parse(text = text, keep.source = TRUE),
    error = function(e) NULL
  )

  # Failed to parse, or yielded empty expression
  if (length(expr) == 0) {
    return(text)
  }

  packages <- extract_package_attach(expr)
  register_attached_packages(packages)

  out <- highlight::highlight(
    parse.output = expr,
    renderer = pkgdown_renderer(),
    detective = pkgdown_detective,
    output = NULL
  )
  paste0(out, collapse = "")
}

pkgdown_renderer <- function() {
  formatter <- function(tokens, styles, ...) {
    href <- href_tokens(tokens, styles)
    linked <- !is.na(href)
    tokens[linked] <- a(tokens[linked], href[linked])

    styled <- !is.na(styles)
    tokens[styled] <- sprintf("<span class='%s'>%s</span>",
      styles[styled],
      tokens[styled]
    )
    tokens
  }

  highlight::renderer_html(
    header = function(...) character(),
    footer = function(...) character(),
    formatter = formatter
  )
}

href_tokens <- function(tokens, styles) {
  href <- chr_along(tokens)

  # SYMBOL_PACKAGE must always be followed NS_GET (or NS_GET_INT)
  # SYMBOL_FUNCTION_CALL or SYMBOL
  pkg <- which(styles %in% "kw pkg")
  pkg_call <- pkg + 2
  href[pkg_call] <- purrr::map2_chr(
    tokens[pkg_call],
    tokens[pkg],
    href_topic_remote
  )

  call <- which(styles %in% "fu")
  call <- setdiff(call, pkg_call)
  href[call] <- purrr::map_chr(tokens[call], href_topic_local)

  href
}

# KeywordTok = kw,
# DataTypeTok = dt (data types)
# DecValTok = dv (decimal values)
# BaseNTok = bn (values with a base other than 10)
# FloatTok = fl (float values)
# CharTok = ch (a character)
# StringTok = st (strings)
# CommontTok = co,
# OtherTok = ot
# AlertTok = al (warning messages)
# FunctionTok = fu (function calls),
# RegionMarkerTok = re ( region markers.)
# ErrorTok = er.
#
# Token list comes from gram.c
pkgdown_detective <- function(x, ...) {
  data <- utils::getParseData(x)
  token <- data$token[data$terminal]

  token_style <- c(
    STR_CONST            = "st",
    NUM_CONST            = "fl",
    NULL_CONST           = "kw",
    SYMBOL               = "no",
    FUNCTION             = "kw",
    INCOMPLETE_STRING    = "al",
    LEFT_ASSIGN          = "kw",
    EQ_ASSIGN            = "kw",
    RIGHT_ASSIGN         = "kw",
    LBB                  = "kw",  # [[
    FOR                  = "kw",
    IN                   = "kw",
    IF                   = "kw",
    ELSE                 = "kw",
    WHILE                = "kw",
    NEXT                 = "kw",
    BREAK                = "kw",
    REPEAT               = "kw",
    GT                   = "kw",
    GE                   = "kw",
    LT                   = "kw",
    LE                   = "kw",
    EQ                   = "kw",
    NE                   = "kw",
    AND                  = "kw",
    OR                   = "kw",
    AND2                 = "kw",
    OR2                  = "kw",
    NS_GET               = "kw ns",
    NS_GET_INT           = "kw ns",
    COMMENT              = "co",
    LINE_DIRECTIVE       = "co",
    SYMBOL_FORMALS       = "no",
    EQ_FORMALS           = "kw",
    EQ_SUB               = "kw",
    SYMBOL_SUB           = "kw",
    SYMBOL_FUNCTION_CALL = "fu",
    SYMBOL_PACKAGE       = "kw pkg",
    COLON_ASSIGN         = "kw",
    SLOT                 = "kw",
    LOW                  = "kw",
    TILDE                = "kw",
    NOT                  = "kw",
    UNOT                 = "kw",
    SPECIAL              = "kw",
    UPLUS                = "kw",
    UMINUS               = "kw"
  )

  unname(token_style[token])
}
