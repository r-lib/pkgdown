Start off by building the different versions of the package:

```
devtools::load_all()
# Build dev version of docs
override <- list(development = list(mode = "devel"))
pkg <- as_pkgdown(test_path("assets/version-dropdown/"), override = override)
pkg$version = "1.0.0.9000"
build_site(pkg)

# Build previous versions - release (1.0.0)
pkg <- as_pkgdown(test_path("assets/version-dropdown/"))
build_site(pkg)

# Build previous versions - oldrel (0.9)
override <- list(destination = "docs/0.9")
pkg <- as_pkgdown(test_path("assets/version-dropdown/"), override = override)
pkg$version = "0.9.0"
build_site(pkg)

# Build previous versions - oldest (0.8)
override <- list(destination = "docs/0.8")
pkg <- as_pkgdown(test_path("assets/version-dropdown/"), override = override)
pkg$version = "0.8.1"
build_site(pkg)
```

Navigate to the correct directory and start up a webserver:

```
python -m http.server 8080
```
