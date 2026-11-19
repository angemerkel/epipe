# CLAUDE.md

Guidance for Claude Code (claude.ai/code) when working in this repository.

## Project

`epipe` is an R package that runs a DNA-methylation analysis pipeline for Illumina arrays (450K, EPIC, EPICv2): IDATs → QC, filtering and normalization → differentially methylated positions (limma) and regions (DMRcate) → pathway enrichment → Quarto HTML reports. The pipeline is orchestrated with `targets`/`tarchetypes`, so every step is cached and only steps whose inputs changed are rebuilt.

This repository is a fork of [ijcBIT/epipe](https://github.com/ijcBIT/epipe) that modernizes the package: it must install and run on current R/Bioconductor, produce correct outputs, and be covered by tests. Backward compatibility with the original behaviour is not required.

## Branching (GitHub Flow)

- `master` is the only long-lived branch: always working, the default branch, and changed only through pull requests.
- Each change gets a short-lived branch off `master`, named by type (`fix/…`, `feat/…`, `test/…`, `ci/…`, `docs/…`), linked to one GitHub issue and merged through one PR (PR description says `Fixes #N`). Delete the branch after merging.
- Merge PRs with "Rebase and merge" or a merge commit, never squash, so the individual commits stay readable.
- Releases are tags on `master` (`v0.1.0`, …) with a matching `NEWS.md` entry and DESCRIPTION version.
- `upstream` ([ijcBIT/epipe](https://github.com/ijcBIT/epipe)) is fetch-only; never push to it. Contributing back is a separate, deliberate PR to that repository.
- Transition: the existing `development` branch carries the initial modernization and is merged into `master` with one PR, then retired.

## Development commands

``` r
devtools::document()   # regenerate man/ and NAMESPACE from roxygen comments (roxygen2 8.x); never edit those by hand
renv::install(".")     # reinstall the local checkout; required after ANY change to R/ or inst/
devtools::test()       # unit tests (tests/testthat)
devtools::check()      # full package check
```

Reinstalling matters because the pipeline calls functions as `epipe::fn` and loads the report with `system.file("_qmd/report.qmd", package = "epipe")`: it always runs the *installed* package, not the source tree. Run `renv::install(".")` and `devtools::test()` from outside the repo root, or loading the package drops stray copies of `_targets.R`, `config.R` and `report_files/` there (see `.onAttach` below). This is a temporary workaround until the copying moves from `.onAttach` into an explicit `init_project()` function.

Dependencies are managed with renv. Bioconductor packages must be requested explicitly (`renv::install("bioc::minfi")`), and the Quarto CLI must be on PATH.

## Running the pipeline

Run the pipeline in a dedicated run directory outside the repository:

``` r
library(epipe)   # .onAttach copies _targets.R, config.R and report_files/ into getwd() if absent
# edit ./config.R
epipe::run()     # = targets::tar_make()
targets::tar_make(names = "dmps_example_EPICv2")  # build one target; names are <target>_<dataset>
targets::tar_read(dmps_example_EPICv2)
```

The bundled EPICv2 example (`inst/extdata/EPICv2`) takes \~25 min and \~3.5 GB. Results go to `results/` and `analysis/`, the cache to `_targets/`. An interrupted run resumes from the cache.

## Architecture

- **`inst/_targets.R` defines the pipeline.** It sources the user's `config.R`, builds a `values` data.table with one row per dataset in `data_paths`, and wraps the per-dataset pipeline in `tarchetypes::tar_map(values = values, names = data_names, ...)`. `tar_combine` then merges per-dataset summaries into `results/full_summary.csv`.
- **`inst/config.R`** is the template users edit: paths, `arraytype`, `norm_function`, filters, contrasts, covariates, DMP/DMR thresholds and report variants. A new per-dataset setting must also be added to the `values` table in `_targets.R`.
- **Normalization by symbol substitution.** `_targets.R` calls `epipe::norm(filtered)`, but no `norm` function exists: `values$norm` holds `rlang::syms(norm_function)`, so `tar_map` rewrites `norm` into e.g. `epipe::noob`. The options are the functions in `R/normalization_methods.R`.
- **`R/`** holds one analysis function (or a few) per file, each called from a target. Exported `filter` and `quantile` shadow the dplyr/stats functions, so always namespace-qualify.
- **Large beta matrices** are stored as file-backed `bigstatsr` FBMs (`betas_disk`) and passed together with `betas_idx` (row/column names) to `top_beta`, `mod` and `DMPextr`.
- **Dynamic branching:** `topN` fans out PCA, correlation plots, biplots and heatmaps via `pattern = map(...)`.
- **Reports:** `tar_quarto_rep` renders `inst/_qmd/report.qmd` once per report variant (`report_colab`, `report_analyst` in `config.R`), passing paths and dataset values as JSON params; `report.qmd` includes the `_*.qmd` child sections.
- **Storage:** `format = "qs"` is backed by `qs2` (targets \>= 1.11). The archived `qs` package does not build on R \>= 4.6, so never call `qs::`.
- **targets does not track code inside the epipe package**, only globals in `_targets.R`. After reinstalling, targets whose package function changed are *not* rebuilt: use `targets::tar_invalidate()` or a fresh run directory, and copy the updated `inst/_targets.R` into the run directory (`.onAttach` never overwrites an existing copy).

## Conventions

- Keep diffs minimal and focused; don't reformat existing code.
- Folders returned by `make_results_dirs()` end in `/` with no double slashes; callers append file names with `paste0(folder, file)`.
- Output files are named `<dataset>_<thing>.<ext>`. When renaming an output, update every `inst/_qmd/` template that references it.
- Take contrast names from the model (`colnames(model$contrasts)`), not from filtered results: contrasts without hits must still be reported, with zero counts.
- Namespace-qualify calls to other packages and declare each one in DESCRIPTION `Imports`.
- Commit messages: short lowercase imperative subject, plus a body explaining *why* when it isn't obvious. Reference the GitHub issue a change addresses.
- Record all user-visible changes in `NEWS.md`, including new functionality, bug fixes, changes to analysis results, configuration defaults, output formats, and breaking changes. Do not document purely internal refactoring unless it affects users.

## Working with Claude Code

- Claude proposes changes; the maintainer reviews and approves them before they are committed or published. Anything public (pushes, pull requests, issues) needs explicit approval.
- Every bug fix comes with a regression test where feasible.
- Changes that affect pipeline outputs are verified with an end-to-end run of the EPICv2 example, not only with unit tests. Report what was verified and how.
- Known problems are tracked as GitHub issues, not in this file.

## Workflow for common changes

- **New analysis step:** function in `R/` with roxygen and `@export` → `devtools::document()` → `tar_target` in `inst/_targets.R` → optional report section in `inst/_qmd/` → tests → `renv::install(".")` → end-to-end run.
- **New dependency:** add it to `Imports` in DESCRIPTION (Bioconductor packages also need `biocViews:` to resolve; GitHub-only ones need `Remotes:`).