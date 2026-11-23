# epipe (development version)

## Breaking changes

* `library(epipe)` no longer writes files into the working directory. To set up a new analysis folder, run `epipe::init_project()` once: it copies `_targets.R`, `config.R` and `report_files/` there and keeps any of them that already exist, unless `overwrite = TRUE` (#4).

## Bug fixes

* The HTML reports now show their images. The plots are embedded in the HTML file, so a report can be opened or shared on its own, and the link to minfi's QC report (`Report.pdf`) is relative to the report (#5).

## Development

* The unit tests now run automatically on GitHub for every pull request and every push to `master`, using R 4.6 and Bioconductor 3.23 (the official Bioconductor Docker image).
* `.Rbuildignore` is now part of the repository, so builds from a GitHub checkout leave out development files.

# epipe 0.1.0

First release of this fork of [ijcBIT/epipe](https://github.com/ijcBIT/epipe). It brings the pipeline back to a working state on current R and Bioconductor (tested with R 4.6.1, Bioconductor 3.23 and Ubuntu 24.04). The bundled EPICv2 example runs end to end. Some output files also have new, consistent names (see "Output file names").

## Installation and dependencies

* epipe now installs with one command, `pak::pak("angemerkel/epipe")`, which also installs all dependencies from CRAN, Bioconductor and GitHub. To make this work, `DESCRIPTION` now has:
  * `biocViews:`, so installers find the Bioconductor packages
  * `Remotes: markgene/maxprobes`, for the dependency that is only on GitHub
  * jsonlite, knitr, rmarkdown and tibble, which were used but not declared
* epipe now requires R >= 4.6.
* The archived `qs` package, which no longer builds on R 4.6, has been replaced. Targets stored with `format = "qs"` now use `qs2` (targets >= 1.11), and the EPICv2 cross-reactive probe mask is read with `readRDS()`.
* `library(epipe)` no longer attaches ggpp and ggpmisc.

## Bug fixes

* `summary.csv` and `results/full_summary.csv` now list every contrast in the model. A contrast without DMPs or DMRs used to be dropped; it now appears with zero counts. A contrast with DMPs but no DMRs gets 0 DMRs instead of `NA`.
* `results/full_summary.csv` is written to the right place, and its `experiment` column holds the dataset name instead of the internal target name. The same fix applies to the combined sample sheet.
* Leukocyte deconvolution downloads the sesame `leukocyte.betas` reference data when it is not cached, instead of failing.
* Output folders no longer contain double slashes.

## Output file names

The original pipeline ran, but some file names came out malformed because of small bugs: the `.png` extension added twice, a misspelling, and a dataset name joined without a separator. The report templates had been written to match these names, so the reports still worked. The names are now consistent. Scripts that read these files by their old names need updating.

* DMP plots are saved as `DMP_count.png`, `DMP_count_facet.png`, `DMP_annCGI.png` and `DMP_annGenomic.png` (previously `DMP_count.png_1.png.png` to `DMP_count.png_4.png.png`).
* Volcano plots are saved as `volcanoplot_<contrast>.png` (previously misspelled `volacanoplot_<contrast>.png`).
* DMR results are saved as `<dataset>_dmrs.xlsx` and `<dataset>_dmrs_summary_full.csv` (previously `_<dataset>.xlsx` and `full_dmrs_summary<dataset>.csv`).

## Removed

* The `future` and `clustermq` settings in `_targets.R`. They only applied to `tar_make_future()` and `tar_make_clustermq()`, both deprecated in targets. Run the pipeline with `epipe::run()` or `targets::tar_make()`.
* `crew_cluster_config.R`, an unused helper hard-coded to another institute's cluster.
* As a result, epipe currently no longer supports running the pipeline on an HPC cluster. The cluster setup above was unfinished and relied on outdated targets features, so this release removes it to focus on a clean, working pipeline on a single machine. HPC support will be added back later, using the current targets approach (`crew` controllers).
* The `dmps_f` example dataset. It was unused, and most of its columns loaded as empty vectors.

## Development

* epipe now has an automated test suite; the original package had no tests. The tests use testthat (`tests/testthat/`) and run with `devtools::test()`. They use small made-up tables, so they need no IDAT files and finish in seconds.
* The first tests cover the result summaries, including a regression test for the dropped zero-hit contrasts, the results folder paths and the DMP plot file names. Every future bug fix comes with a test.
* Documentation is generated with roxygen2 8.1.1.
