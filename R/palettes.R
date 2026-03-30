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
    slate_blue  = "#4A6D7C",
    muted_teal  = "#5B8A72",
    dusty_rose  = "#A8687A",
    rust        = "#9F522C",
    light_gold  = "#F8E69B"
  )
  if (is.null(n)) return(pal)
  if (n > length(pal)) {
    warning("n exceeds palette size (12). Recycling colours.")
    return(rep_len(pal, n))
  }
  pal[seq_len(n)]
}

#' Get a DEN colour by position
#'
#' Returns the \emph{i}-th colour in the DEN palette (1-based),
#' matching Stata's \code{den1}–\code{den12} colour names.
#'
#' @param i Integer position (1–12).
#' @return A single hex colour string.
#' @export
#' @examples
#' den_color(1)   # gold
#' den_color(3)   # red
den_color <- function(i) {
  pal <- den_palette()
  if (i < 1 || i > length(pal)) {
    stop("i must be between 1 and ", length(pal), ", got ", i)
  }
  unname(pal[i])
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
  slate_blue  = "#4A6D7C",
  muted_teal  = "#5B8A72",
  dusty_rose  = "#A8687A",
  rust        = "#9F522C",
  light_gold  = "#F8E69B"
)
