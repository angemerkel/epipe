#' Embed an image in the HTML report
#'
#' Returns the image as a base64 `data:` URI, for use in the markdown of the
#' report templates (`![caption](uri)`). `tar_quarto_rep()` renders the report
#' from the installed package, so pandoc looks for image paths relative to the
#' package's `_qmd/` folder rather than the run directory; a `data:` URI needs
#' no path at all.
#'
#' @param ... Path components, passed to [file.path()], relative to the
#'   working directory (the run directory while the report is rendered).
#' @return A `data:` URI. If the file does not exist, its file name, with a
#'   warning, so that the report still renders.
#' @noRd
report_image <- function(...) {
  path <- file.path(...)
  if (!file.exists(path)) {
    warning("Report image not found: ", path, call. = FALSE)
    return(basename(path))
  }
  knitr::image_uri(path)
}

#' Link to a results file from the HTML report
#'
#' Returns the path of `path` relative to `report_folder`, so that links in a
#' report keep working when the results folder is moved or shared.
#'
#' @param path File to link to, relative to the working directory.
#' @param report_folder Folder the report is saved in, relative to the working
#'   directory.
#' @return A relative path, e.g. `"../QC/Report.pdf"`.
#' @noRd
report_link <- function(path, report_folder) {
  as.character(fs::path_rel(path, start = report_folder))
}
