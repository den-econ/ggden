#' Save a ggplot with DEN defaults
#'
#' Wrapper around \code{\link[ggplot2]{ggsave}} with sensible defaults:
#' 300 dpi, white background, tight bounding box.
#'
#' @param filename File path to save to (e.g. \code{"output.png"}).
#' @param plot Plot to save (default: last plot).
#' @param width Width in inches (default 10).
#' @param height Height in inches (default 6).
#' @param dpi Resolution (default 300).
#' @param bg Background colour (default \code{"white"}).
#' @param ... Additional arguments passed to \code{\link[ggplot2]{ggsave}}.
#' @return Invisible file path (from \code{ggsave}).
#' @export
#' @examples
#' \dontrun{
#' p <- ggplot(mtcars, aes(wt, mpg)) + geom_point() + theme_den()
#' den_save("mtcars.png", p)
#' }
den_save <- function(filename, plot = ggplot2::last_plot(),
                     width = 10, height = 6, dpi = 300,
                     bg = "white", ...) {
  ggplot2::ggsave(
    filename = filename,
    plot     = plot,
    width    = width,
    height   = height,
    dpi      = dpi,
    bg       = bg,
    ...
  )
}
