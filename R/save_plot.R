#' Save Plot to File
#'
#' This function saves a plot to a file in PNG format, at 100 dpi for both
#' plot types, so that `width` and `height` give the size in pixels.
#'
#' @param object A plot object (base R plot or ggplot2 plot).
#' @param filename Name of the file to save the plot. `.png` is appended unless
#'   the name already ends with it. An existing file with that name is
#'   overwritten.
#' @param width Width of the plot in pixels (default: 480).
#' @param height Height of the plot in pixels (default: 620).
#' @param path Directory path for saving the plot (default: "./"). It is created
#'   if it does not exist; an error is raised if it cannot be created or is not
#'   writable.
#' @return The plot object.
#'
save_plot <- function(object, filename, width = 480, height = 620, path = "./") {
  # Create the folder if it doesn't exist; stop with an error naming the
  # folder if it can't be created or written to
  if (!dir.exists(path) && !dir.create(path, recursive = TRUE, showWarnings = FALSE)) {
    stop("Could not create folder '", path, "' to save plot '", filename, "'.",
         call. = FALSE)
  }
  if (file.access(path, mode = 2) != 0) {
    stop("Folder '", path, "' is not writable; could not save plot '", filename, "'.",
         call. = FALSE)
  }
  file <- file.path(path, paste0(sub("\\.png$", "", filename), ".png"))

  # Determine the type of plot (base R or ggplot2)
  is_ggplot <- inherits(object, "gg") || inherits(object, "ggplot")

  # Save the plot based on its type; an existing file is overwritten
  if (is_ggplot) {
    # For ggplot2 plots, use ggsave; 100 dpi gives width x height pixels
    ggplot2::ggsave(
      file,
      plot = object,
      width = width / 100,
      height = height / 100,
      dpi = 100
    )
  } else {
    # For base R plots, draw on a png device; it is closed even if drawing fails
    grDevices::png(
      file = file,
      width = width,
      height = height,
      units = "px",
      res = 100
    )
    device <- grDevices::dev.cur()
    on.exit(grDevices::dev.off(device), add = TRUE)
    print(object)
  }

  return(object)
}
