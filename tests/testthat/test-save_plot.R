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
