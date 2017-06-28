data_authors <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)
  author_info <- data_author_info(pkg)

  all <- pkg %>%
    pkg_authors() %>%
    purrr::map(author_list, author_info)

  main <- pkg %>%
    pkg_authors(c("aut", "cre", "fnd")) %>%
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

  list_with_heading(authors, "Developers")
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
  "acp" = "art&nbsp;copyist",
  "adi" = "art&nbsp;director",
  "art" = "artist",
  "ard" = "artistic&nbsp;director",
  "asg" = "assignee",
  "asn" = "associated&nbsp;name",
  "att" = "attributed&nbsp;name",
  "auc" = "auctioneer",
  "aut" = "author",
  "aqt" = "author&nbsp;in&nbsp;quotations&nbsp;or&nbsp;text&nbsp;abstracts",
  "aft" = "author&nbsp;of&nbsp;afterword,&nbsp;colophon,&nbsp;etc.",
  "aud" = "author&nbsp;of&nbsp;dialog",
  "aui" = "author&nbsp;of&nbsp;introduction,&nbsp;etc.",
  "ato" = "autographer",
  "ant" = "bibliographic&nbsp;antecedent",
  "bnd" = "binder",
  "bdd" = "binding&nbsp;designer",
  "blw" = "blurb&nbsp;writer",
  "bkd" = "book&nbsp;designer",
  "bkp" = "book&nbsp;producer",
  "bjd" = "bookjacket&nbsp;designer",
  "bpd" = "bookplate&nbsp;designer",
  "bsl" = "bookseller",
  "brl" = "braille&nbsp;embosser",
  "brd" = "broadcaster",
  "cll" = "calligrapher",
  "ctg" = "cartographer",
  "cas" = "caster",
  "cns" = "censor",
  "chr" = "choreographer",
  "cng" = "cinematographer",
  "cli" = "client",
  "cor" = "collection&nbsp;registrar",
  "col" = "collector",
  "clt" = "collotyper",
  "clr" = "colorist",
  "cmm" = "commentator",
  "cwt" = "commentator&nbsp;for&nbsp;written&nbsp;text",
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
  "csp" = "consultant&nbsp;to&nbsp;a&nbsp;project",
  "cos" = "contestant",
  "cot" = "contestant-appellant",
  "coe" = "contestant-appellee",
  "cts" = "contestee",
  "ctt" = "contestee-appellant",
  "cte" = "contestee-appellee",
  "ctr" = "contractor",
  "ctb" = "contributor",
  "cpc" = "copyright&nbsp;claimant",
  "cph" = "copyright&nbsp;holder",
  "crr" = "corrector",
  "crp" = "correspondent",
  "cst" = "costume&nbsp;designer",
  "cou" = "court&nbsp;governed",
  "crt" = "court&nbsp;reporter",
  "cov" = "cover&nbsp;designer",
  "cre" = "maintainer",
  "cur" = "curator",
  "dnc" = "dancer",
  "dtc" = "data&nbsp;contributor",
  "dtm" = "data&nbsp;manager",
  "dte" = "dedicatee",
  "dto" = "dedicator",
  "dfd" = "defendant",
  "dft" = "defendant-appellant",
  "dfe" = "defendant-appellee",
  "dgg" = "degree&nbsp;granting&nbsp;institution",
  "dgs" = "degree&nbsp;supervisor",
  "dln" = "delineator",
  "dpc" = "depicted",
  "dpt" = "depositor",
  "dsr" = "designer",
  "drt" = "director",
  "dis" = "dissertant",
  "dbp" = "distribution&nbsp;place",
  "dst" = "distributor",
  "dnr" = "donor",
  "drm" = "draftsman",
  "dub" = "dubious&nbsp;author",
  "edt" = "editor",
  "edc" = "editor&nbsp;of&nbsp;compilation",
  "edm" = "editor&nbsp;of&nbsp;moving&nbsp;image&nbsp;work",
  "elg" = "electrician",
  "elt" = "electrotyper",
  "enj" = "enacting&nbsp;jurisdiction",
  "eng" = "engineer",
  "egr" = "engraver",
  "etr" = "etcher",
  "evp" = "event&nbsp;place",
  "exp" = "expert",
  "fac" = "facsimilist",
  "fld" = "field&nbsp;director",
  "fmd" = "film&nbsp;director",
  "fds" = "film&nbsp;distributor",
  "flm" = "film&nbsp;editor",
  "fmp" = "film&nbsp;producer",
  "fmk" = "filmmaker",
  "fpy" = "first&nbsp;party",
  "frg" = "forger",
  "fmo" = "former&nbsp;owner",
  "fnd" = "funder",
  "gis" = "geographic&nbsp;information&nbsp;specialist",
  "hnr" = "honoree",
  "hst" = "host",
  "his" = "host&nbsp;institution",
  "ilu" = "illuminator",
  "ill" = "illustrator",
  "ins" = "inscriber",
  "itr" = "instrumentalist",
  "ive" = "interviewee",
  "ivr" = "interviewer",
  "inv" = "inventor",
  "isb" = "issuing&nbsp;body",
  "jud" = "judge",
  "jug" = "jurisdiction&nbsp;governed",
  "lbr" = "laboratory",
  "ldr" = "laboratory&nbsp;director",
  "lsa" = "landscape&nbsp;architect",
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
  "lgd" = "lighting&nbsp;designer",
  "ltg" = "lithographer",
  "lyr" = "lyricist",
  "mfp" = "manufacture&nbsp;place",
  "mfr" = "manufacturer",
  "mrb" = "marbler",
  "mrk" = "markup&nbsp;editor",
  "med" = "medium",
  "mdc" = "metadata&nbsp;contact",
  "mte" = "metal-engraver",
  "mtk" = "minute&nbsp;taker",
  "mod" = "moderator",
  "mon" = "monitor",
  "mcp" = "music&nbsp;copyist",
  "msd" = "musical&nbsp;director",
  "mus" = "musician",
  "nrt" = "narrator",
  "osp" = "onscreen&nbsp;presenter",
  "opn" = "opponent",
  "orm" = "organizer",
  "org" = "originator",
  "oth" = "other",
  "own" = "owner",
  "pan" = "panelist",
  "ppm" = "papermaker",
  "pta" = "patent&nbsp;applicant",
  "pth" = "patent&nbsp;holder",
  "pat" = "patron",
  "prf" = "performer",
  "pma" = "permitting&nbsp;agency",
  "pht" = "photographer",
  "ptf" = "plaintiff",
  "ptt" = "plaintiff-appellant",
  "pte" = "plaintiff-appellee",
  "plt" = "platemaker",
  "pra" = "praeses",
  "pre" = "presenter",
  "prt" = "printer",
  "pop" = "printer&nbsp;of&nbsp;plates",
  "prm" = "printmaker",
  "prc" = "process&nbsp;contact",
  "pro" = "producer",
  "prn" = "production&nbsp;company",
  "prs" = "production&nbsp;designer",
  "pmn" = "production&nbsp;manager",
  "prd" = "production&nbsp;personnel",
  "prp" = "production&nbsp;place",
  "prg" = "programmer",
  "pdr" = "project&nbsp;director",
  "pfr" = "proofreader",
  "prv" = "provider",
  "pup" = "publication&nbsp;place",
  "pbl" = "publisher",
  "pbd" = "publishing&nbsp;director",
  "ppt" = "puppeteer",
  "rdd" = "radio&nbsp;director",
  "rpc" = "radio&nbsp;producer",
  "rce" = "recording&nbsp;engineer",
  "rcd" = "recordist",
  "red" = "redaktor",
  "ren" = "renderer",
  "rpt" = "reporter",
  "rps" = "repository",
  "rth" = "research&nbsp;team&nbsp;head",
  "rtm" = "research&nbsp;team&nbsp;member",
  "res" = "researcher",
  "rsp" = "respondent",
  "rst" = "respondent-appellant",
  "rse" = "respondent-appellee",
  "rpy" = "responsible&nbsp;party",
  "rsg" = "restager",
  "rsr" = "restorationist",
  "rev" = "reviewer",
  "rbr" = "rubricator",
  "sce" = "scenarist",
  "sad" = "scientific&nbsp;advisor",
  "aus" = "screenwriter",
  "scr" = "scribe",
  "scl" = "sculptor",
  "spy" = "second&nbsp;party",
  "sec" = "secretary",
  "sll" = "seller",
  "std" = "set&nbsp;designer",
  "stg" = "setting",
  "sgn" = "signer",
  "sng" = "singer",
  "sds" = "sound&nbsp;designer",
  "spk" = "speaker",
  "spn" = "sponsor",
  "sgd" = "stage&nbsp;director",
  "stm" = "stage&nbsp;manager",
  "stn" = "standards&nbsp;body",
  "str" = "stereotyper",
  "stl" = "storyteller",
  "sht" = "supporting&nbsp;host",
  "srv" = "surveyor",
  "tch" = "teacher",
  "tcd" = "technical&nbsp;director",
  "tld" = "television&nbsp;director",
  "tlp" = "television&nbsp;producer",
  "ths" = "thesis&nbsp;advisor",
  "trc" = "transcriber",
  "trl" = "translator",
  "tyd" = "type&nbsp;designer",
  "tyg" = "typographer",
  "uvp" = "university&nbsp;place",
  "vdg" = "videographer",
  "vac" = "voice&nbsp;actor",
  "wit" = "witness",
  "wde" = "wood&nbsp;engraver",
  "wdc" = "woodcutter",
  "wam" = "writer&nbsp;of&nbsp;accompanying&nbsp;material",
  "wac" = "writer&nbsp;of&nbsp;added&nbsp;commentary",
  "wal" = "writer&nbsp;of&nbsp;added&nbsp;lyrics",
  "wat" = "writer&nbsp;of&nbsp;added&nbsp;text",
  "win" = "writer&nbsp;of&nbsp;introduction",
  "wpr" = "writer&nbsp;of&nbsp;preface",
  "wst" = "writer&nbsp;of&nbsp;supplementary&nbsp;textual&nbsp;content"
)
