write_png <- function(path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  grDevices::png(path, width = 10, height = 10)
  grid::grid.newpage()
  grDevices::dev.off()
}

test_that("report_image returns a data URI for an existing image", {
  run_dir <- withr::local_tempdir()
  withr::local_dir(run_dir)
  write_png("results/QC/plot.png")

  uri <- report_image("results/QC/", "plot.png")

  expect_match(uri, "^data:image/png;base64,")
})

test_that("report_image warns and returns the file name for a missing image", {
  run_dir <- withr::local_tempdir()
  withr::local_dir(run_dir)

  expect_warning(out <- report_image("results/QC/", "missing.png"), "not found")
  expect_equal(out, "missing.png")
})

test_that("report_link is relative to the report folder", {
  expect_equal(
    report_link("results/ex/QC//Report.pdf", "results/ex/reports/"),
    "../QC/Report.pdf"
  )
})

# Regression test for #5: tar_quarto_rep() renders the report from the
# installed package's _qmd/ folder while R code runs in the run directory, so
# pandoc could not find images given as paths relative to the run directory.
test_that("images are embedded when the report is rendered from another folder", {
  skip_on_cran()
  skip_if(is.null(quarto::quarto_path()), "Quarto CLI not available")

  run_dir <- withr::local_tempdir()
  qmd_dir <- withr::local_tempdir()
  write_png(file.path(run_dir, "results/QC/plot.png"))

  qmd <- file.path(qmd_dir, "report.qmd")
  writeLines(c(
    "---",
    "format: html",
    "embed-resources: true",
    "---",
    "```{r}",
    "#| include: false",
    paste("img <-", paste(deparse(report_image), collapse = "\n")),
    "```",
    "![Plot](`r img(\"results/QC/\", \"plot.png\")`){#fig-plot}"
  ), qmd)

  withr::with_dir(
    run_dir,
    quarto::quarto_render(qmd, execute_dir = run_dir, quiet = TRUE)
  )

  html <- readLines(file.path(qmd_dir, "report.html"), warn = FALSE)
  img_src <- regmatches(html, regexpr('<img[^>]*src="[^"]{0,30}', html))
  expect_length(img_src, 1)
  expect_match(img_src, 'src="data:image/png;base64,')
})
