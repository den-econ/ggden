#' DEN discrete colour scale
#'
#' Maps discrete aesthetics to the DEN palette.
#'
#' @param ... Additional arguments passed to
#'   \code{\link[ggplot2]{discrete_scale}}.
#' @return A ggplot2 scale object.
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(iris, aes(Sepal.Length, Sepal.Width, colour = Species)) +
#'   geom_point() +
#'   scale_color_den() +
#'   theme_den()
scale_color_den <- function(...) {
  ggplot2::discrete_scale(
    aesthetics = "colour",
    palette    = den_pal(),
    ...
  )
}

#' @rdname scale_color_den
#' @export
scale_colour_den <- scale_color_den

#' DEN discrete fill scale
#'
#' Maps discrete fill aesthetics to the DEN palette.
#'
#' @param ... Additional arguments passed to
#'   \code{\link[ggplot2]{discrete_scale}}.
#' @return A ggplot2 scale object.
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mpg, aes(class, fill = class)) +
#'   geom_bar() +
#'   scale_fill_den() +
#'   theme_den()
scale_fill_den <- function(...) {
  ggplot2::discrete_scale(
    aesthetics = "fill",
    palette    = den_pal(),
    ...
  )
}


# Internal palette function (returns a function that maps n -> colours)
den_pal <- function() {
  function(n) {
    pal <- unname(den_palette())
    if (n > length(pal)) {
      warning("n exceeds DEN palette size (9). Recycling colours.")
      return(rep_len(pal, n))
    }
    pal[seq_len(n)]
  }
}
