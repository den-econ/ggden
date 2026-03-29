#' DEN colour palette
#'
#' The full DEN palette contains 12 colours in three tiers:
#' Core (1--3), Standard (4--7), and Extended (8--12).
#' Use \code{den_palette(n)} to return the first \code{n} colours,
#' or \code{den_colors} for the named vector.
#'
#' @param n Number of colours to return (default: all 12).
#' @return A character vector of hex colour codes.
#' @export
#' @examples
#' den_palette()
#' den_palette(4)
den_palette <- function(n = NULL) {
  pal <- c(
    gold        = "#EEC051",
    dark_brown  = "#845B24",
    red         = "#C00000",
    bright_gold = "#FFC000",
    tan         = "#A19574",
    dark_grey   = "#3A3A3A",
    deep_amber  = "#935200",
    light_gold  = "#F8E69B",
    warm_sand   = "#C3986D",
    rose_brown  = "#B58B80",
    rust        = "#9F522C",
    olive_tan   = "#8B8679"
  )
  if (is.null(n)) return(pal)
  if (n > length(pal)) {
    warning("n exceeds palette size (12). Recycling colours.")
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
  gold        = "#EEC051",
  dark_brown  = "#845B24",
  red         = "#C00000",
  bright_gold = "#FFC000",
  tan         = "#A19574",
  dark_grey   = "#3A3A3A",
  deep_amber  = "#935200",
  light_gold  = "#F8E69B",
  warm_sand   = "#C3986D",
  rose_brown  = "#B58B80",
  rust        = "#9F522C",
  olive_tan   = "#8B8679"
)
