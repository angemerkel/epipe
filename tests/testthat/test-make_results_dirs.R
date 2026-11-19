test_that("folders end in a single slash and contain no double slashes", {
  base <- withr::local_tempdir()
  for (suffix in c("", "/", "//")) {
    dirs <- make_results_dirs(
      subf = "ds1",
      results_folder = paste0(base, "/results", suffix),
      analysis_folder = paste0(base, "/analysis", suffix)
    )
    paths <- unlist(dirs)

    expect_true(all(endsWith(paths, "/")))
    expect_false(any(grepl("//", paths, fixed = TRUE)))
  }
})

test_that("folders are created and named after the dataset", {
  base <- withr::local_tempdir()
  dirs <- make_results_dirs(
    subf = "ds1",
    results_folder = file.path(base, "results"),
    analysis_folder = file.path(base, "analysis")
  )

  expect_true(all(dir.exists(unlist(dirs))))
  expect_equal(dirs$dmp_folder, paste0(base, "/results/ds1/dmps/"))
  expect_equal(dirs$ss_clean_path, paste0(base, "/analysis/ds1/"))
  expect_equal(dirs$results_folder, paste0(base, "/results/"))
})

test_that("callers can append file names with paste0()", {
  base <- withr::local_tempdir()
  dirs <- make_results_dirs(subf = "ds1", results_folder = file.path(base, "results"))

  expect_equal(paste0(dirs$dmrs_folder, "ds1_dmrs.xlsx"),
               paste0(base, "/results/ds1/dmrs/ds1_dmrs.xlsx"))
})
