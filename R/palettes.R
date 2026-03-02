#' DEN colour palette
#'
#' The full DEN palette contains 9 colours.
#' Use \code{den_palette(n)} to return the first \code{n} colours,
#' or \code{den_colors} for the named vector.
#'
#' @param n Number of colours to return (default: all 9).
#' @return A character vector of hex colour codes.
#' @export
#' @examples
#' den_palette()
#' den_palette(4)
den_palette <- function(n = NULL) {
  pal <- c(
    gold   = "#f0a22e",
    brown  = "#a5644e",
    red    = "#c00000",
    tan    = "#a19574",
    grey   = "#3a3a3a",
    sand   = "#c3986d",
    amber  = "#a0640c",
    rose   = "#b58b80",
    orange = "#c17529"
  )
  if (is.null(n)) return(pal)
  if (n > length(pal)) {
    warning("n exceeds palette size (9). Recycling colours.")
    return(rep_len(pal, n))
  }
  pal[seq_len(n)]
}

#' Named DEN colours
#'
#' A named character vector for easy single-colour access, e.g.
#' \code{den_colors["gold"]}.
#'
#' @export
den_colors <- c(
  gold   = "#f0a22e",
  brown  = "#a5644e",
  red    = "#c00000",
  tan    = "#a19574",
  grey   = "#3a3a3a",
  sand   = "#c3986d",
  amber  = "#a0640c",
  rose   = "#b58b80",
  orange = "#c17529"
)
