test_that("default names give one .png per plot, without a doubled extension", {
  dir <- withr::local_tempdir()
  plots <- plotDMP(fake_dmps(), path = dir)

  expect_length(plots, 4)
  expect_true(all(vapply(plots, ggplot2::is_ggplot, logical(1))))
  expect_setequal(
    list.files(dir),
    c("DMP_count.png", "DMP_count_facet.png", "DMP_annCGI.png", "DMP_annGenomic.png")
  )
})

test_that("custom names with or without .png are used as given", {
  dir <- withr::local_tempdir()
  names <- c("ds1_count.png", "ds1_facet", "ds1_cgi.png", "ds1_genomic")
  plotDMP(fake_dmps(), names = names, path = dir)

  expect_setequal(list.files(dir),
                  c("ds1_count.png", "ds1_facet.png", "ds1_cgi.png", "ds1_genomic.png"))
})

test_that("a single name is used as a prefix", {
  dir <- withr::local_tempdir()
  plotDMP(fake_dmps(), names = "ds1_dmp", path = dir)

  expect_setequal(list.files(dir), paste0("ds1_dmp_", 1:4, ".png"))
})

test_that("nothing is written without a path", {
  dir <- withr::local_tempdir()
  withr::local_dir(dir)
  plots <- plotDMP(fake_dmps())

  expect_length(plots, 4)
  expect_length(list.files(dir, recursive = TRUE), 0)
})
