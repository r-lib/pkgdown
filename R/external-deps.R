external_dependencies <- function(pkg, call = caller_env()) {
  purrr::compact(list(
    fontawesome::fa_html_dependency(),
    cached_dependency(
      name = "headroom",
      version = "0.11.0",
      files = list(
        list(
          url = "https://cdnjs.cloudflare.com/ajax/libs/headroom/0.11.0/headroom.min.js",
          integrity = "sha256-AsUX4SJE1+yuDu5+mAVzJbuYNPHj/WroHuZ8Ir/CkE0="
        ),
        list(
          url = "https://cdnjs.cloudflare.com/ajax/libs/headroom/0.11.0/jQuery.headroom.min.js",
          integrity = "sha256-ZX/yNShbjqsohH1k95liqY9Gd8uOiE1S4vZc+9KQ1K4="
        )
      )
    ),
    cached_dependency(
      name = "bootstrap-toc",
      version = "1.0.1",
      files = list(
        list(
          url = "https://cdn.jsdelivr.net/gh/afeld/bootstrap-toc@v1.0.1/dist/bootstrap-toc.min.js",
          integrity = "sha256-4veVQbu7//Lk5TSmc7YV48MxtMy98e26cf5MrgZYnwo="
        )
      )
    ),
    cached_dependency(
      name = "clipboard.js",
      version = "2.0.11",
      files = list(
        list(
          url = "https://cdnjs.cloudflare.com/ajax/libs/clipboard.js/2.0.11/clipboard.min.js",
          integrity = "sha512-7O5pXpc0oCRrxk8RUfDYFgn0nO1t+jLuIOQdOMRp4APB7uZ4vSjspzp5y6YDtDs4VzUSTbWzBFZ/LKJhnyFOKw=="
        )
      )
    ),
    cached_dependency(
      name = "search",
      version = "1.0.0",
      files = list(
        list(
          url = "https://cdnjs.cloudflare.com/ajax/libs/fuse.js/6.4.6/fuse.min.js",
          integrity = "sha512-KnvCNMwWBGCfxdOtUpEtYgoM59HHgjHnsVGSxxgz7QH1DYeURk+am9p3J+gsOevfE29DV0V+/Dd52ykTKxN5fA=="
        ),
        list(
          url = "https://cdnjs.cloudflare.com/ajax/libs/autocomplete.js/0.38.0/autocomplete.jquery.min.js",
          integrity = "sha512-GU9ayf+66Xx2TmpxqJpliWbT5PiGYxpaG8rfnBEk1LL8l1KGkRShhngwdXK1UgqhAzWpZHSiYPc09/NwDQIGyg=="
        ),
        list(
          url = "https://cdnjs.cloudflare.com/ajax/libs/mark.js/8.11.1/mark.min.js",
          integrity = "sha512-5CYOlHXGh6QpOFA/TeTylKLWfB3ftPsde7AnmhuitiTX4K5SqCLBeKro6sPS8ilsz1Q4NRx3v8Ko2IBiszzdww=="
        )
      )
    ),
    math_dependency(pkg, call = call)
  ))
}

math_dependency <- function(pkg, call = caller_env()) {
  math <- config_math_rendering(pkg)
  if (math == "mathjax") {
    cached_dependency(
      name = "MathJax",
      version = "3.2.2",
      files = list(
        list(
          url = "https://cdnjs.cloudflare.com/ajax/libs/mathjax/3.2.2/es5/tex-chtml.min.js",
          integrity = "sha512-T8xxpazDtODy3WOP/c6hvQI2O9UPdARlDWE0CvH1Cfqc0TXZF6GZcEKL7tIR8VbfS/7s/J6C+VOqrD6hIo++vQ=="
        )
      )
    )
  } else {
    NULL
  }
}

cached_dependency <- function(name, version, files) {
  cache_dir <- path(tools::R_user_dir("pkgdown", "cache"), name, version)
  dir_create(cache_dir)

  for (file in files) {
    cache_path <- path(cache_dir, path_file(file$url))
    if (!file_exists(cache_path)) {
      utils::download.file(file$url, cache_path, quiet = TRUE, mode = "wb")
      check_integrity(cache_path, file$integrity)
    }
  }
  dep_files <- path_rel(dir_ls(cache_dir), cache_dir)

  htmltools::htmlDependency(
    name = name,
    version = version,
    src = cache_dir,
    script = dep_files[path_ext(dep_files) == "js"],
    stylesheet = dep_files[path_ext(dep_files) == "css"]
  )
}

check_integrity <- function(path, integrity) {
  parsed <- parse_integrity(integrity)
  if (!parsed$size %in% c(256L, 384L, 512L)) {
    cli::cli_abort(
      "{.field integrity} must use SHA-256, SHA-384, or SHA-512",
      .internal = TRUE
    )
  }

  hash <- compute_hash(path, parsed$size)
  if (hash != parsed$hash) {
    cli::cli_abort(
      "Downloaded asset does not match known integrity",
      .internal = TRUE
    )
  }

  invisible()
}

compute_hash <- function(path, size) {
  con <- file(path, encoding = "UTF-8")
  openssl::base64_encode(openssl::sha2(con, size))
}

parse_integrity <- function(x) {
  size <- as.integer(regmatches(x, regexpr("(?<=^sha)\\d{3}", x, perl = TRUE)))
  hash <- regmatches(x, regexpr("(?<=^sha\\d{3}-).+", x, perl = TRUE))

  list(size = size, hash = hash)
}
