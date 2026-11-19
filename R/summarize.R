#' Summarize DMPs and DMRs
#'
#' This function summarizes Differentially Methylated Positions (DMPs) and Differentially Methylated Regions (DMRs).
#'
#' @param dmps Data.table containing DMP information.
#' @param dmrs Data.table containing DMR information.
#' @param contrasts Optional character vector with all contrasts of the model.
#'   Contrasts without any DMP/DMR are reported with zero counts instead of being dropped.
#' @param path Path to save the summary, defaults to "results/".
#'
#' @return A data.table summarizing DMPs and DMRs.
#'
#' @import data.table
#' @export

summarize <- function(dmps, dmrs, contrasts = NULL, path = "results/") {
  dir.create(path, recursive = TRUE, showWarnings = FALSE)
  sdmps <- summary_dmps(dmps, write = FALSE)
  sdmrs <- summary_dmrs(dmrs, write = FALSE)
  s <- merge(sdmps, sdmrs, by = "Contrast", all = TRUE)
  if (!is.null(contrasts)) {
    s <- merge(data.table::data.table(Contrast = contrasts), s, by = "Contrast", all = TRUE)
  }
  # Contrasts missing from one of the tables have no DMPs/DMRs: report 0, not NA
  count_cols <- setdiff(names(s), "Contrast")
  for (col in count_cols) data.table::set(s, which(is.na(s[[col]])), col, 0L)
  data.table::fwrite(s, file.path(sub("/+$", "", path), "summary.csv"))
  return(s)
}
