#' DEN ggplot2 theme
#'
#' A clean, publication-ready theme following DEN visual identity.
#' Removes top/right borders, uses light grid lines, positions the legend
#' above the plot, and applies DEN font sizing.
#'
#' @param base_size Base font size (default 12).
#' @param base_family Base font family (default \code{"sans"}).
#' @param legend_position Legend position: \code{"top"} (default),
#'   \code{"right"}, \code{"bottom"}, \code{"left"}, or \code{"none"}.
#' @return A ggplot2 theme object.
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_point() +
#'   theme_den()
theme_den <- function(base_size = 12, base_family = "sans",
                      legend_position = "top") {

  half_line <- base_size / 2

  theme_minimal(base_size = base_size, base_family = base_family) %+replace%
    theme(
      # --- Panel ---
      panel.grid.major = element_line(colour = "grey90", linewidth = 0.3),
      panel.grid.minor = element_blank(),
      panel.border     = element_blank(),

      # --- Axes ---
      axis.line.x      = element_line(colour = "grey30", linewidth = 0.4),
      axis.line.y      = element_line(colour = "grey30", linewidth = 0.4),
      axis.ticks        = element_line(colour = "grey30", linewidth = 0.3),
      axis.title        = element_text(size = base_size, colour = "grey20"),
      axis.title.x      = element_text(margin = margin(t = half_line)),
      axis.title.y      = element_text(margin = margin(r = half_line), angle = 90),
      axis.text         = element_text(size = base_size * 0.85, colour = "grey30"),

      # --- Legend ---
      legend.position   = legend_position,
      legend.background = element_blank(),
      legend.key        = element_blank(),
      legend.title      = element_blank(),
      legend.text       = element_text(size = base_size * 0.85),
      legend.spacing.x  = unit(0.3, "cm"),

      # --- Title / Subtitle ---
      plot.title        = element_text(
        size = base_size * 1.2, face = "bold", colour = "grey10",
        hjust = 0, margin = margin(b = half_line)
      ),
      plot.subtitle     = element_text(
        size = base_size, colour = "grey30",
        hjust = 0, margin = margin(b = half_line)
      ),
      plot.caption      = element_text(
        size = base_size * 0.75, colour = "grey50",
        hjust = 1, margin = margin(t = half_line)
      ),

      # --- Strip (facets) ---
      strip.text        = element_text(
        size = base_size * 0.9, face = "bold", colour = "grey20",
        margin = margin(b = half_line * 0.5, t = half_line * 0.5)
      ),
      strip.background  = element_blank(),

      # --- Margins ---
      plot.margin       = margin(half_line, half_line, half_line, half_line)
    )
}
