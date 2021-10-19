library(jsonlite)
library(purrr)
library(dplyr)
library(fs)

# Pandoc styles are based on KDE default styles:
# https://docs.kde.org/stable5/en/applications/katepart/highlight.html#kate-highlight-default-styles
# But in HTML use two letter abbreviations:
# https://github.com/jgm/skylighting/blob/a1d02a0db6260c73aaf04aae2e6e18b569caacdc/skylighting-core/src/Skylighting/Format/HTML.hs#L117-L147
# Summary at
# https://docs.google.com/spreadsheets/d/1JhBtQSCtQ2eu2RepLTJONFdLEnhM3asUyMMLYE3tdYk/edit#gid=0

class <- c(
  "Keyword"        = "span.kw",
  "DataType"       = "span.dt",
  "DecVal"         = "span.dv",
  "BaseN"          = "span.bn",
  "Float"          = "span.fl",
  "Char"           = "span.ch",
  "String"         = "span.st",
  "Comment"        = "span.co",
  "Other"          = "span.ot",
  "Others"         = "span.ot", # both spellings used in themes
  "Alert"          = "span.al",
  "Function"       = "span.fu",
  "RegionMarker"   = "span.re",
  "Error"          = "span.er",
  "Constant"       = "span.cn",
  "SpecialChar"    = "span.sc",
  "VerbatimString" = "span.vs",
  "SpecialString"  = "span.ss",
  "Import"         = "span.im",
  "Documentation"  = "span.do",
  "Annotation"     = "span.an",
  "CommentVar"     = "span.cv",
  "Variable"       = "span.va",
  "ControlFlow"    = "span.cf",
  "Operator"       = "span.op",
  "BuiltIn"        = "span.bu",
  "Extension"      = "span.ex",
  "Preprocessor"   = "span.pp",
  "Attribute"      = "span.at",
  "Information"    = "span.in",
  "Warning"        = "span.wa",
  "Normal"         = ""
)

theme_json <- function(name) {
  jsonlite::read_json(paste0(
    "https://raw.githubusercontent.com/quarto-dev/quarto-cli/",
    "main/src/resources/pandoc/highlight-styles/", name
  ))
}

theme_df <- function(theme) {
  background <- theme$`background-color` %||% theme$`editor-colors`$BackgroundColor
  print(background)

  df <- purrr::map_df(theme$`text-styles`, compact, .id = "name")
  df %>%
    rename(color = any_of("text-color"), background = any_of("background-color")) %>%
    mutate(class = class[name], name = name, `selected-text-color` = NULL) %>%
    arrange(class) %>%
    structure(background = background)
}

style_to_css <- function(name, class, color = NA, background = NA, bold = FALSE, italic = FALSE, underline = FALSE, ...) {
  attr <- c(
    if (!is.na(color)) paste0("color:", color),
    if (!is.na(background)) paste0("background-color:", background),
    if (!is.na(bold) && bold) "font-weight: bold",
    if (!is.na(italic) && italic) "font-style: italic",
    if (!is.na(underline) && underline) "text-decoration: underline"
  )

  paste0("pre code ", class, " /* ", name, " */ {", paste0(attr, collapse = "; "), "}")
}


safe_format <- function(x) {
  ifelse(is.na(x), NA, format(x))
}

theme_as_css <- function(df, path = stdout()) {
  css <- df %>%
    filter(!is.na(class)) %>%
    mutate(name = safe_format(name), class = safe_format(class)) %>%
    pmap_chr(style_to_css)

  if ("background" %in% names(attributes(df))) {
    css <- c(paste0("pre {background-color: ", attr(df, "background"), "}"), css)
  }

  base::writeLines(css, path)
}

save_theme <- function(theme, name) {
  df <- theme_df(theme)
  theme_as_css(df, path("inst", "highlight-styles", path_ext_set(name, "css")))
}

json <- gh::gh("/repos/{owner}/{repo}/contents/{path}",
  owner = "quarto-dev",
  repo = "quarto-cli",
  path = "src/resources/pandoc/highlight-styles"
)

theme_names <- json %>% map_chr("name")
theme_json <- map(theme_names, theme_json)
names(theme_json) <- theme_names
iwalk(theme_json, save_theme)


# themes <- theme_names %>% set_names() %>% map_df(theme_df, .id = "theme")
# themes %>% count(name, sort = T)
# themes %>% count(theme, is.na(color)) %>% print(n = Inf)
# themes %>% filter(is.na(class)) %>% print(n = Inf)

arrow <- theme_df("dracula")
theme_as_css(arrow)
