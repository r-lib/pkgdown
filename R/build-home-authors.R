data_authors <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)
  author_info <- data_author_info(pkg)

  included_roles <- pkg$meta$roles_include %||% c("aut", "cre", "fnd")

  all <- pkg %>%
    pkg_authors() %>%
    purrr::map(author_list, author_info)

  main <- pkg %>%
    pkg_authors(included_roles) %>%
    purrr::map(author_list, author_info)

  needs_page <- length(main) != length(all)

  print_yaml(list(
    all = all,
    main = main,
    needs_page = needs_page
  ))
}

pkg_authors <- function(pkg, role = NULL) {
  authors <- unclass(pkg$desc$get_authors())

  if (is.null(role)) {
    authors
  } else {
    purrr::keep(authors, ~ any(.$role %in% role))
  }
}


data_author_info <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  defaults <- list(
    "Hadley Wickham" = list(
      href = "http://hadley.nz"
    ),
    "RStudio" = list(
      href = "https://www.rstudio.com",
      html = "<img src='http://tidyverse.org/rstudio-logo.svg' height='24' />"
    )
  )

  utils::modifyList(defaults, pkg$meta$authors %||% list())
}


data_home_sidebar_authors <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)
  data <- data_authors(pkg)

  authors <- data$main %>% purrr::map_chr(author_desc)
  if (data$needs_page) {
    authors <- c(authors, "<a href='authors.html'>All authors...</li>")
  }

  paste0(
    '<div id="sidebar_authors">\n',
    list_with_heading(authors, "Developers"),
    '\n</div>'
  )
}

build_authors <- function(pkg = ".", path = "docs", depth = 0L) {
  pkg <- as_pkgdown(pkg)

  data <- list(
    pagetitle = "Authors",
    authors = data_authors(pkg)$all
  )

  render_page(pkg, "authors", data, file.path(path, "authors.html"), depth = depth)
}

author_name <- function(x, authors) {
  name <- format_author_name(x$given, x$family)

  if (!(name %in% names(authors)))
    return(name)

  author <- authors[[name]]

  if (!is.null(author$html)) {
    name <- author$html
  }

  if (is.null(author$href)) {
    name
  } else {
    paste0("<a href='", author$href, "'>", name, "</a>")
  }
}

format_author_name <- function(given, family) {
  given <- paste(given, collapse = " ")

  if (is.null(family)) {
    given
  } else {
    paste0(given, " ", family)
  }
}

author_list <- function(x, authors_info, comment = FALSE) {
  name <- author_name(x, authors_info)

  roles <- paste0(role_lookup[x$role], collapse = ", ")
  substr(roles, 1, 1) <- toupper(substr(roles, 1, 1))

  list(
    name = name,
    roles = roles,
    comment = x$comment
  )
}

author_desc <- function(x, comment = TRUE) {
  paste(
    x$name,
    "<br />\n<small class = 'roles'>", x$roles, "</small>",
    if (comment && !is.null(x$comment))
      paste0("<br/>\n<small>(", x$comment, ")</small>")
  )
}

role_lookup <- c(
  "abr" = "abridger",
  "act" = "actor",
  "adp" = "adapter",
  "rcp" = "addressee",
  "anl" = "analyst",
  "anm" = "animator",
  "ann" = "annotator",
  "apl" = "appellant",
  "ape" = "appellee",
  "app" = "applicant",
  "arc" = "architect",
  "arr" = "arranger",
  "acp" = "art copyist",
  "adi" = "art director",
  "art" = "artist",
  "ard" = "artistic director",
  "asg" = "assignee",
  "asn" = "associated name",
  "att" = "attributed name",
  "auc" = "auctioneer",
  "aut" = "author",
  "aqt" = "author in quotations or text abstracts",
  "aft" = "author of afterword, colophon, etc.",
  "aud" = "author of dialog",
  "aui" = "author of introduction, etc.",
  "ato" = "autographer",
  "ant" = "bibliographic antecedent",
  "bnd" = "binder",
  "bdd" = "binding designer",
  "blw" = "blurb writer",
  "bkd" = "book designer",
  "bkp" = "book producer",
  "bjd" = "bookjacket designer",
  "bpd" = "bookplate designer",
  "bsl" = "bookseller",
  "brl" = "braille embosser",
  "brd" = "broadcaster",
  "cll" = "calligrapher",
  "ctg" = "cartographer",
  "cas" = "caster",
  "cns" = "censor",
  "chr" = "choreographer",
  "cng" = "cinematographer",
  "cli" = "client",
  "cor" = "collection registrar",
  "col" = "collector",
  "clt" = "collotyper",
  "clr" = "colorist",
  "cmm" = "commentator",
  "cwt" = "commentator for written text",
  "com" = "compiler",
  "cpl" = "complainant",
  "cpt" = "complainant-appellant",
  "cpe" = "complainant-appellee",
  "cmp" = "composer",
  "cmt" = "compositor",
  "ccp" = "conceptor",
  "cnd" = "conductor",
  "con" = "conservator",
  "csl" = "consultant",
  "csp" = "consultant to a project",
  "cos" = "contestant",
  "cot" = "contestant-appellant",
  "coe" = "contestant-appellee",
  "cts" = "contestee",
  "ctt" = "contestee-appellant",
  "cte" = "contestee-appellee",
  "ctr" = "contractor",
  "ctb" = "contributor",
  "cpc" = "copyright claimant",
  "cph" = "copyright holder",
  "crr" = "corrector",
  "crp" = "correspondent",
  "cst" = "costume designer",
  "cou" = "court governed",
  "crt" = "court reporter",
  "cov" = "cover designer",
  "cre" = "maintainer",
  "cur" = "curator",
  "dnc" = "dancer",
  "dtc" = "data contributor",
  "dtm" = "data manager",
  "dte" = "dedicatee",
  "dto" = "dedicator",
  "dfd" = "defendant",
  "dft" = "defendant-appellant",
  "dfe" = "defendant-appellee",
  "dgg" = "degree granting institution",
  "dgs" = "degree supervisor",
  "dln" = "delineator",
  "dpc" = "depicted",
  "dpt" = "depositor",
  "dsr" = "designer",
  "drt" = "director",
  "dis" = "dissertant",
  "dbp" = "distribution place",
  "dst" = "distributor",
  "dnr" = "donor",
  "drm" = "draftsman",
  "dub" = "dubious author",
  "edt" = "editor",
  "edc" = "editor of compilation",
  "edm" = "editor of moving image work",
  "elg" = "electrician",
  "elt" = "electrotyper",
  "enj" = "enacting jurisdiction",
  "eng" = "engineer",
  "egr" = "engraver",
  "etr" = "etcher",
  "evp" = "event place",
  "exp" = "expert",
  "fac" = "facsimilist",
  "fld" = "field director",
  "fmd" = "film director",
  "fds" = "film distributor",
  "flm" = "film editor",
  "fmp" = "film producer",
  "fmk" = "filmmaker",
  "fpy" = "first party",
  "frg" = "forger",
  "fmo" = "former owner",
  "fnd" = "funder",
  "gis" = "geographic information specialist",
  "hnr" = "honoree",
  "hst" = "host",
  "his" = "host institution",
  "ilu" = "illuminator",
  "ill" = "illustrator",
  "ins" = "inscriber",
  "itr" = "instrumentalist",
  "ive" = "interviewee",
  "ivr" = "interviewer",
  "inv" = "inventor",
  "isb" = "issuing body",
  "jud" = "judge",
  "jug" = "jurisdiction governed",
  "lbr" = "laboratory",
  "ldr" = "laboratory director",
  "lsa" = "landscape architect",
  "led" = "lead",
  "len" = "lender",
  "lil" = "libelant",
  "lit" = "libelant-appellant",
  "lie" = "libelant-appellee",
  "lel" = "libelee",
  "let" = "libelee-appellant",
  "lee" = "libelee-appellee",
  "lbt" = "librettist",
  "lse" = "licensee",
  "lso" = "licensor",
  "lgd" = "lighting designer",
  "ltg" = "lithographer",
  "lyr" = "lyricist",
  "mfp" = "manufacture place",
  "mfr" = "manufacturer",
  "mrb" = "marbler",
  "mrk" = "markup editor",
  "med" = "medium",
  "mdc" = "metadata contact",
  "mte" = "metal-engraver",
  "mtk" = "minute taker",
  "mod" = "moderator",
  "mon" = "monitor",
  "mcp" = "music copyist",
  "msd" = "musical director",
  "mus" = "musician",
  "nrt" = "narrator",
  "osp" = "onscreen presenter",
  "opn" = "opponent",
  "orm" = "organizer",
  "org" = "originator",
  "oth" = "other",
  "own" = "owner",
  "pan" = "panelist",
  "ppm" = "papermaker",
  "pta" = "patent applicant",
  "pth" = "patent holder",
  "pat" = "patron",
  "prf" = "performer",
  "pma" = "permitting agency",
  "pht" = "photographer",
  "ptf" = "plaintiff",
  "ptt" = "plaintiff-appellant",
  "pte" = "plaintiff-appellee",
  "plt" = "platemaker",
  "pra" = "praeses",
  "pre" = "presenter",
  "prt" = "printer",
  "pop" = "printer of plates",
  "prm" = "printmaker",
  "prc" = "process contact",
  "pro" = "producer",
  "prn" = "production company",
  "prs" = "production designer",
  "pmn" = "production manager",
  "prd" = "production personnel",
  "prp" = "production place",
  "prg" = "programmer",
  "pdr" = "project director",
  "pfr" = "proofreader",
  "prv" = "provider",
  "pup" = "publication place",
  "pbl" = "publisher",
  "pbd" = "publishing director",
  "ppt" = "puppeteer",
  "rdd" = "radio director",
  "rpc" = "radio producer",
  "rce" = "recording engineer",
  "rcd" = "recordist",
  "red" = "redaktor",
  "ren" = "renderer",
  "rpt" = "reporter",
  "rps" = "repository",
  "rth" = "research team head",
  "rtm" = "research team member",
  "res" = "researcher",
  "rsp" = "respondent",
  "rst" = "respondent-appellant",
  "rse" = "respondent-appellee",
  "rpy" = "responsible party",
  "rsg" = "restager",
  "rsr" = "restorationist",
  "rev" = "reviewer",
  "rbr" = "rubricator",
  "sce" = "scenarist",
  "sad" = "scientific advisor",
  "aus" = "screenwriter",
  "scr" = "scribe",
  "scl" = "sculptor",
  "spy" = "second party",
  "sec" = "secretary",
  "sll" = "seller",
  "std" = "set designer",
  "stg" = "setting",
  "sgn" = "signer",
  "sng" = "singer",
  "sds" = "sound designer",
  "spk" = "speaker",
  "spn" = "sponsor",
  "sgd" = "stage director",
  "stm" = "stage manager",
  "stn" = "standards body",
  "str" = "stereotyper",
  "stl" = "storyteller",
  "sht" = "supporting host",
  "srv" = "surveyor",
  "tch" = "teacher",
  "tcd" = "technical director",
  "tld" = "television director",
  "tlp" = "television producer",
  "ths" = "thesis advisor",
  "trc" = "transcriber",
  "trl" = "translator",
  "tyd" = "type designer",
  "tyg" = "typographer",
  "uvp" = "university place",
  "vdg" = "videographer",
  "vac" = "voice actor",
  "wit" = "witness",
  "wde" = "wood engraver",
  "wdc" = "woodcutter",
  "wam" = "writer of accompanying material",
  "wac" = "writer of added commentary",
  "wal" = "writer of added lyrics",
  "wat" = "writer of added text",
  "win" = "writer of introduction",
  "wpr" = "writer of preface",
  "wst" = "writer of supplementary textual content"
)
