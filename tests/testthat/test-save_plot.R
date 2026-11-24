test_that("save_plot adds .png only when the name does not end with it", {
  dir <- withr::local_tempdir()
  plt <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point()

  save_plot(plt, filename = "plain", path = dir)
  save_plot(plt, filename = "with_ext.png", path = dir)

  expect_setequal(list.files(dir), c("plain.png", "with_ext.png"))
})

test_that("save_plot names base graphics plots the same way", {
  dir <- withr::local_tempdir()
  plt <- structure(list(), class = "fake_base_plot")
  registerS3method("print", "fake_base_plot", function(x, ...) {
    graphics::plot(1:3)
    invisible(x)
  })

  save_plot(plt, filename = "base.png", path = dir)

  expect_equal(list.files(dir), "base.png")
})

# Regression test for #6: the pipeline passed a file name ending in .png, and
# save_plot() appended another one.
test_that("corpca saves a single .png even when the name ends with .png", {
  dir <- withr::local_tempdir()
  set.seed(1)
  n <- 8
  betas <- matrix(stats::runif(200 * n), nrow = 200,
                  dimnames = list(paste0("cg", 1:200), paste0("s", 1:n)))
  metadata <- data.frame(Batch = rep(1:2, each = n / 2),
                         Age = seq(30, 65, length.out = n),
                         row.names = paste0("s", 1:n))

  corpca(betas, metadata, path = dir, filename = "ds_pca_corrplot200.png")

  expect_equal(list.files(dir), "ds_pca_corrplot200.png")
})

png_size <- function(file) {
  header <- readBin(file, "raw", n = 24)
  c(width = readBin(header[17:20], "integer", endian = "big"),
    height = readBin(header[21:24], "integer", endian = "big"))
}

test_that("ggplot2 and base graphics plots are saved at the same pixel size (#11)", {
  dir <- withr::local_tempdir()
  gg <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  base <- structure(list(), class = "fake_base_plot")
  registerS3method("print", "fake_base_plot", function(x, ...) {
    graphics::plot(1:3)
    invisible(x)
  })

  save_plot(gg, filename = "gg", path = dir)
  save_plot(base, filename = "base", path = dir)
  save_plot(gg, filename = "gg_small", path = dir, width = 300, height = 200)

  expect_equal(png_size(file.path(dir, "gg.png")), c(width = 480L, height = 620L))
  expect_equal(png_size(file.path(dir, "base.png")), c(width = 480L, height = 620L))
  expect_equal(png_size(file.path(dir, "gg_small.png")), c(width = 300L, height = 200L))
})

test_that("an existing file is overwritten without a warning", {
  dir <- withr::local_tempdir()
  small <- ggplot2::ggplot(data.frame(x = 1, y = 1), ggplot2::aes(x, y))

  save_plot(small, filename = "same", path = dir, width = 100, height = 100)
  expect_no_warning(save_plot(small, filename = "same", path = dir, width = 200, height = 150))

  expect_equal(png_size(file.path(dir, "same.png")), c(width = 200L, height = 150L))
})

test_that("a folder that cannot be created gives an error naming it (#11)", {
  dir <- withr::local_tempdir()
  blocker <- file.path(dir, "not_a_folder")
  writeLines("", blocker)
  plt <- ggplot2::ggplot(data.frame(x = 1, y = 1), ggplot2::aes(x, y))

  expect_error(save_plot(plt, filename = "p", path = file.path(blocker, "plots")),
               "Could not create folder '.*not_a_folder/plots'")
})

test_that("a folder that is not writable gives an error naming it (#11)", {
  skip_on_os("windows")
  skip_if(Sys.info()[["user"]] == "root", "root can write to read-only folders")
  dir <- withr::local_tempdir()
  Sys.chmod(dir, "0555")
  withr::defer(Sys.chmod(dir, "0755"))
  plt <- ggplot2::ggplot(data.frame(x = 1, y = 1), ggplot2::aes(x, y))

  expect_error(save_plot(plt, filename = "p", path = dir), "is not writable")
})

test_that("the png device is closed when drawing fails (#11)", {
  dir <- withr::local_tempdir()
  broken <- structure(list(), class = "broken_base_plot")
  registerS3method("print", "broken_base_plot", function(x, ...) stop("drawing failed"))
  devices_before <- grDevices::dev.list()

  expect_error(save_plot(broken, filename = "broken", path = dir), "drawing failed")

  expect_equal(grDevices::dev.list(), devices_before)
})
