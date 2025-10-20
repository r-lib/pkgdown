# Render page with template

Each page is composed of four templates: "head", "header", "content",
and "footer". Each of these templates is rendered using the `data`, and
then assembled into an overall page using the "layout" template.

## Usage

``` r
render_page(pkg = ".", name, data, path, depth = NULL, quiet = FALSE)

data_template(pkg = ".", depth = 0L)
```

## Arguments

- pkg:

  Path to package to document.

- name:

  Name of the template (e.g. "home", "vignette", "news")

- data:

  Data for the template.

  This is automatically supplemented with three lists:

  - `site`: `title` and path to `root`.

  - `yaml`: the `template` key from `_pkgdown.yml`.

  - `package`: package metadata including `name` and`version`.

  See the full contents by running `data_template()`.

- path:

  Location to create file; relative to destination directory.

- depth:

  Depth of path relative to base directory.

- quiet:

  If `quiet`, will suppress output messages
