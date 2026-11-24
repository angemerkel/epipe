# Small limma fit on artificial beta values: 3 groups of 2 samples, probes with
# different group differences, so that topTable() reorders them.
fake_dmp_input <- function() {
  set.seed(1)
  n_probes <- 40
  group <- factor(rep(c("A", "B", "C"), each = 2))
  shift_b <- seq(-0.3, 0.3, length.out = n_probes)
  shift_c <- rev(shift_b) / 2
  base <- stats::runif(n_probes, 0.35, 0.65)
  betas <- cbind(base, base, base + shift_b, base + shift_b, base + shift_c, base + shift_c) +
    matrix(stats::rnorm(n_probes * 6, sd = 0.01), n_probes)
  probes <- paste0("cg", sprintf("%02d", seq_len(n_probes)))
  dimnames(betas) <- list(probes, paste0("s", 1:6))

  design <- stats::model.matrix(~ 0 + group)
  colnames(design) <- levels(group)
  contrasts <- limma::makeContrasts(contrasts = c("A-B", "A-C"), levels = design)
  fit <- limma::eBayes(limma::contrasts.fit(limma::lmFit(betas, design), contrasts))

  ann <- data.frame(Name = probes, chr = "chr1", row.names = probes)
  list(betas = betas, fit = fit, ann = ann, group = group)
}

group_mean_diff <- function(input, contrast) {
  groups <- strsplit(contrast, "-")[[1]]
  m <- input$betas
  rowMeans(m[, input$group == groups[1]]) - rowMeans(m[, input$group == groups[2]])
}

# Regression test for #13: diff_meanMeth was taken from the wrong rows because
# the beta row index was overwritten after topTable() sorted the probes.
test_that("diff_meanMeth is the group-mean difference of each row's own probe", {
  input <- fake_dmp_input()

  res <- DMPextr(fit = input$fit, ContrastsDM = colnames(input$fit$contrasts),
                 p.value = 1, beta_normalized = input$betas, mDiff = 0,
                 ann = input$ann, writeOut = FALSE)
  res <- data.table::as.data.table(res)

  expect_setequal(unique(res$Contrast), c("A-B", "A-C"))
  for (ct in c("A-B", "A-C")) {
    r <- res[Contrast == ct]
    expect_equal(nrow(r), 40)
    expected <- group_mean_diff(input, ct)[r$Name]
    expect_equal(r$diff_meanMeth, unname(expected), tolerance = 1e-12)
    expect_equal(r$diff_meanMeth, r$logFC, tolerance = 1e-12)
  }
})

test_that("diff_meanMeth is correct with a file-backed beta matrix", {
  input <- fake_dmp_input()
  fbm <- bigstatsr::FBM(nrow(input$betas), ncol(input$betas), init = input$betas)
  idx <- list(rn = rownames(input$betas), cn = colnames(input$betas))

  res <- DMPextr(fit = input$fit, ContrastsDM = "A-B", p.value = 1,
                 beta_normalized = fbm, betas_idx = idx, mDiff = 0,
                 ann = input$ann, writeOut = FALSE)

  expected <- group_mean_diff(input, "A-B")[res$Name]
  expect_equal(res$diff_meanMeth, unname(expected), tolerance = 1e-12)
})

test_that("the mDiff filter uses each probe's own difference", {
  input <- fake_dmp_input()

  res <- DMPextr(fit = input$fit, ContrastsDM = "A-B", p.value = 1,
                 beta_normalized = input$betas, mDiff = 0.15,
                 ann = input$ann, writeOut = FALSE)

  diffs <- group_mean_diff(input, "A-B")
  expect_setequal(res$Name, names(diffs)[abs(diffs) >= 0.15])
})
