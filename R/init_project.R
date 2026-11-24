#' Set Up a Folder for a Pipeline Run
#'
#' Copies the files a pipeline run needs into `path`: the pipeline definition
#' `_targets.R` and the configuration template `config.R`. Run it once in a
#' new analysis folder, edit `config.R`, then start the pipeline with [run()].
#'
#' Existing files are kept unless `overwrite = TRUE`. Note that
#' `overwrite = TRUE` also replaces an edited `config.R` with the template.
#'
#' @param path Folder to set up. It is created if it does not exist.
#'   Default is the current working directory.
#' @param overwrite Replace files that already exist in `path`? Default is `FALSE`.
#'
#' @return Invisibly, the paths of the files that were copied.
#'
#' @examples
#' project <- file.path(tempdir(), "my_analysis")
#' init_project(project)
#' list.files(project)
#'
#' @export
init_project <- function(path = ".", overwrite = FALSE) {
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE)
  }

  copied <- character()
  for (item in c("_targets.R", "config.R")) {
    source <- system.file(item, package = "epipe", mustWork = TRUE)
    destination <- file.path(path, item)
    existed <- file.exists(destination)

    if (existed && !overwrite) {
      message("Kept existing ", destination)
      next
    }

    if (!file.copy(source, destination, overwrite = TRUE)) {
      stop("Could not copy ", item, " to ", path)
    }

    message(if (existed) "Replaced " else "Created ", destination)
    copied <- c(copied, destination)
  }

  invisible(copied)
}
