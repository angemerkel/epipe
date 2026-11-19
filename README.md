# EPIPE: (E)pigenetics (PIPE)line

**EPIPE** is a bioinformatics pipeline designed to analyze methylation data from microarrays. It automates the entire workflow, from processing raw data to identifying and annotating differentially methylated positions (DMPs) and regions (DMRs).

Based on the `targets` toolkit, EPIPE ensures efficient and reproducible execution of every analysis step. It includes a customizable configuration file for easy parameter adjustments, allowing users to modify and extend the pipeline to fit their specific analysis needs.

## About this fork

epipe was developed at the Josep Carreras Leukaemia Research Institute ([ijcBIT/epipe](https://github.com/ijcBIT/epipe)). The project was initiated by Angelika Merkel: Izar de Villasante built the pipeline based on her R script for DNA methylation analysis and designed its architecture with `targets`, while she supervised the scientific content. Marina Lladó Vilardell completed the documentation and extended features under her guidance. The original package no longer installs on current R and Bioconductor. This fork, maintained by Angelika Merkel, updates it so that it installs, runs and produces correct results, and adds tests.

**Status:** version 0.1.0. The package installs into an empty R library with one command, and the bundled EPICv2 example runs end to end. Tested with R 4.6.1, Bioconductor 3.23 and Ubuntu 24.04. [NEWS.md](NEWS.md) lists all changes, and open problems are tracked as [issues](https://github.com/angemerkel/epipe/issues).

## Installation

Install epipe and all its dependencies (CRAN, Bioconductor and GitHub) with [pak](https://pak.r-lib.org):

``` r
install.packages("pak")
pak::pak("angemerkel/epipe")
```

Requirements:

- R >= 4.6
- the [Quarto CLI](https://quarto.org/docs/get-started/) on your `PATH`, for the HTML reports
- on Linux, some system libraries for packages built from source. On Ubuntu 24.04 these were needed: `sudo apt install libglpk-dev libgit2-dev libgsl-dev libnlopt-dev cmake libcairo2-dev`

Installing into an empty library takes about 20–25 minutes.

## Quick start

Create a folder for the analysis and run the pipeline from there:

``` r
library(epipe)   # copies _targets.R, config.R and report_files/ into the current folder
# edit config.R: sample sheet, array type, contrasts, thresholds
epipe::run()     # runs targets::tar_make()
```

As shipped, `config.R` analyses the bundled EPICv2 example: 8 samples in three groups. That run takes about 25 minutes and about 3.5 GB of disk space. Results go to `results/` and `analysis/`. Every step is cached in `_targets/`, so an interrupted run resumes where it stopped.
