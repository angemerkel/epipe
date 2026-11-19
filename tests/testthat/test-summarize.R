test_that("contrasts without hits are reported with zero counts", {
  # Regression test: the summary used to keep only contrasts with DMPs/DMRs,
  # so a model contrast without any hits disappeared from summary.csv.
  dir <- withr::local_tempdir()
  s <- summarize(fake_dmps(), fake_dmrs(), contrasts = c("A-B", "A-C", "B-C"), path = dir)

  expect_setequal(s$Contrast, c("A-B", "A-C", "B-C"))
  bc <- s[Contrast == "B-C"]
  expect_true(all(unlist(bc[, -"Contrast"]) == 0))
})

test_that("a contrast with DMPs but no DMRs gets 0 DMRs, not NA", {
  dir <- withr::local_tempdir()
  s <- summarize(fake_dmps(), fake_dmrs(), contrasts = c("A-B", "A-C"), path = dir)

  expect_false(anyNA(s))
  expect_equal(s[Contrast == "A-C", Total_DMRS], 0)
  expect_equal(s[Contrast == "A-C", Total_DMPS], 1)
  expect_equal(s[Contrast == "A-B", Total_DMRS], 2)
})

test_that("counts are right for contrasts with hits", {
  dir <- withr::local_tempdir()
  s <- summarize(fake_dmps(), fake_dmrs(), contrasts = c("A-B", "A-C"), path = dir)
  ab <- s[Contrast == "A-B"]

  expect_equal(ab$Total_DMPS, 3)
  expect_equal(ab$Hyper_DMPS, 2)
  expect_equal(ab$Hypo_DMPS, 1)
  expect_equal(ab$Hyper_DMRS, 1)
  expect_equal(ab$Hypo_DMRS, 1)
  expect_equal(ab$Total_Genes_DMRS, 3)
})

test_that("an empty DMR table still yields one row per contrast", {
  dir <- withr::local_tempdir()
  empty_dmrs <- fake_dmrs()[0]
  s <- summarize(fake_dmps(), empty_dmrs, contrasts = c("A-B", "A-C", "B-C"), path = dir)

  expect_equal(nrow(s), 3)
  expect_true(all(s$Total_DMRS == 0))
  expect_false(anyNA(s))
})

test_that("summary_dmrs returns a typed zero-row table for empty input", {
  s <- summary_dmrs(fake_dmrs()[0], write = FALSE)

  expect_equal(nrow(s), 0)
  expect_named(s, c("Contrast", "Total_DMRS", "Total_Genes_DMRS", "Hyper_DMRS",
                    "Hyper_Genes_DMRS", "Hypo_DMRS", "Hypo_Genes_DMRS"))
  expect_type(s$Contrast, "character")
  expect_type(s$Total_DMRS, "integer")
})

test_that("summary.csv is written into path with or without a trailing slash", {
  for (suffix in c("", "/", "//")) {
    dir <- withr::local_tempdir()
    path <- paste0(dir, suffix)
    summarize(fake_dmps(), fake_dmrs(), contrasts = c("A-B", "A-C"), path = path)

    out <- file.path(dir, "summary.csv")
    expect_true(file.exists(out))
    expect_equal(nrow(data.table::fread(out)), 2)
  }
})
