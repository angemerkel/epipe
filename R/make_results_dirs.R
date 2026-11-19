#' Create Directories for Data Storage in the Pipeline
#'
#' This function creates directories for storing various types of results and plots
#' generated during the pipeline analysis.
#'
#' @param results_folder The main folder to store all results. Default is "./results/".
#' @param analysis_folder The folder to store analysis-specific results. Default is "./analysis/".
#' @param subf A subfolder name to organize results further.
#'
#' @return A list of folder paths created for different purposes.
#'
#' @export
# @examples
# # Create directories with default paths
# make_results_dirs(subf = "sample_analysis")
#
# # Create directories with custom paths
# make_results_dirs(results_folder = "./my_results/", analysis_folder = "./my_analysis/", subf = "custom_analysis")
#'
make_results_dirs <- function(subf, results_folder = "./results/", analysis_folder = "./analysis/") {
  # Build "<base>/<subf>/<sub>/" without duplicated separators; keep the trailing "/"
  # because callers append file names with paste0().
  dir_path <- function(base, ...) {
    p <- do.call(file.path, as.list(c(sub("/+$", "", base), subf, ...)))
    paste0(gsub("/+", "/", p), "/")
  }
  params <- list(
    results_folder = paste0(sub("/+$", "", results_folder), "/"),
    qc_folder = dir_path(results_folder, "QC"),
    ss_clean_path = dir_path(analysis_folder),
    sexplot_folder = dir_path(results_folder, "plots", "sex"),
    bplots_folder = dir_path(results_folder, "plots", "pca", "bplots"),
    corrplot_folder = dir_path(results_folder, "plots", "pca", "corrplot"),
    dmp_folder = dir_path(results_folder, "dmps"),
    dmpplots_folder = dir_path(results_folder, "dmps"),
    dmrs_folder = dir_path(results_folder, "dmrs"),
    pathway_folder = dir_path(results_folder, "gopath"),
    report_folder = dir_path(results_folder, "reports"),
    temp = dir_path(analysis_folder, "temp"),
    heatmap_folder = dir_path(results_folder, "plots", "heatmap"),
    betas_folder = dir_path(results_folder, "betas")
  )
  sapply(params, function(x) dir.create(x, recursive = TRUE, showWarnings = FALSE))

  return(params)
}
