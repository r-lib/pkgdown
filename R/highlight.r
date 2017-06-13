syntax_highlight <- function(text, index = NULL, current = NULL) {
  stopifnot(is.character(text), length(text) == 1)

  expr <- tryCatch(
    parse(text = text, keep.source = TRUE),
    error = function(e) NULL
  )
  if (is.null(expr)) {
    # Failed to parse so give up
    return(text)
  }

  parse_data <- utils::getParseData(expr)
  if (nrow(parse_data) == 0) {
    # Empty
    return(text)
  }

  renderer <- highlight::renderer_html(
    header = function(...) "",
    footer = function(...) "",
    formatter = pkgdown_format(index, current)
  )

  highlight::highlight(
    parse.output = expr,
    renderer = renderer,
    detective = pkgdown_detective,
    output = NULL
  )
}

highlight_capture <- function(...) {
  out <- utils::capture.output(highlight::highlight(...))
  paste0(out, collapse = "\n")
}

pkgdown_format <- function(index, current) {
  function(tokens, styles, ...) {
    call <- styles %in% "fu"
    tokens[call] <- purrr::map2_chr(
      tokens[call],
      tokens[call],
      link_local,
      index = index,
      current = current
    )

    styled <- !is.na(styles)
    tokens[styled] <- sprintf(
      "<span class='%s'>%s</span>",
      styles[styled],
      tokens[styled]
    )
    tokens
  }
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
    NS_GET               = "kw",
    NS_GET_INT           = "kw",
    COMMENT              = "co",
    LINE_DIRECTIVE       = "co",
    SYMBOL_FORMALS       = "no",
    EQ_FORMALS           = "kw",
    EQ_SUB               = "kw",
    SYMBOL_SUB           = "kw",
    SYMBOL_FUNCTION_CALL = "fu",
    SYMBOL_PACKAGE       = "kw",
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
