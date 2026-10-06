#' DEN ggplot2 theme
#'
#' A clean, publication-ready theme following DEN visual identity: no grid
#' lines, axis lines on the left and bottom, legend above the plot.
#'
#' Besides styling, \code{theme_den()} inspects the plot it is added to:
#' \itemize{
#'   \item \strong{Last-value labels.} Every \code{geom_line()} /
#'     \code{geom_step()} / \code{geom_path()} layer gets a label at its
#'     last observation, in the same colour as the line.
#'   \item \strong{Date ticks.} If the x variable is a \code{Date} or
#'     \code{POSIXct} and no x scale has been set, the x ticks end at the
#'     last observation and step backward from it
#'     (see \code{\link{breaks_from_last}}). Any other x (numeric years,
#'     factors, text) is left untouched.
#' }
#' Only layers added \emph{before} \code{theme_den()} are seen, so add it
#' after the geoms. A user-supplied x scale always takes precedence.
#'
#' @param base_size Base font size (default 12).
#' @param base_family Base font family (default \code{"sans"}).
#' @param legend_position Legend position: \code{"top"} (default),
#'   \code{"right"}, \code{"bottom"}, \code{"left"}, or \code{"none"}.
#' @param last_label \code{TRUE} (default) labels the last value of each
#'   line; \code{FALSE} turns labels off; a \code{\link{den_last_label}}
#'   object customises them; a function is used as the number format,
#'   i.e. shorthand for \code{den_last_label(format = f)}.
#' @param date_breaks \code{TRUE} (default) anchors date ticks at the last
#'   observation with an automatic step; a string such as \code{"1 year"}
#'   or \code{"3 months"} fixes the step; \code{FALSE} keeps ggplot2's
#'   default ticks.
#' @return An object that adds the theme (and, where applicable, labels and
#'   an x scale) when added to a ggplot. Use \code{theme_den_base()} where a
#'   plain theme object is required, e.g. \code{theme_set()}.
#' @export
#' @examples
#' library(ggplot2)
#' df <- data.frame(
#'   date   = rep(seq(as.Date("2020-08-01"), as.Date("2026-08-01"), by = "month"), 2),
#'   series = rep(c("Inflasi", "BI Rate"), each = 73),
#'   value  = c(cumsum(rnorm(73, 0, 0.2)) + 3, cumsum(rnorm(73, 0, 0.1)) + 5)
#' )
#' ggplot(df, aes(date, value, colour = series)) +
#'   geom_line() +
#'   scale_color_den() +
#'   theme_den()
theme_den <- function(base_size = 12, base_family = "sans",
                      legend_position = "top", last_label = TRUE,
                      date_breaks = TRUE) {
  if (is.function(last_label)) last_label <- den_last_label(format = last_label)
  if (isTRUE(last_label)) last_label <- den_last_label()
  if (!isFALSE(last_label) && !inherits(last_label, "den_last_label")) {
    stop("`last_label` must be TRUE, FALSE, a function, or den_last_label().",
         call. = FALSE)
  }
  if (!(isTRUE(date_breaks) || isFALSE(date_breaks) ||
        (is.character(date_breaks) && length(date_breaks) == 1))) {
    stop("`date_breaks` must be TRUE, FALSE, or a step such as \"1 year\".",
         call. = FALSE)
  }

  structure(
    list(
      theme = theme_den_base(base_size, base_family, legend_position),
      base_size = base_size,
      legend_position = legend_position,
      last_label = last_label,
      date_breaks = date_breaks
    ),
    class = "den_theme"
  )
}

#' @rdname theme_den
#' @export
theme_den_base <- function(base_size = 12, base_family = "sans",
                           legend_position = "top") {

  half_line <- base_size / 2

  theme_minimal(base_size = base_size, base_family = base_family) %+replace%
    theme(
      # --- Panel ---
      panel.grid.major = element_blank(),
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

#' @exportS3Method ggplot2::ggplot_add
ggplot_add.den_theme <- function(object, plot, ...) {
  plot <- plot + object$theme

  line_layers <- Filter(is_line_layer, plot$layers)
  already_labelled <- any(vapply(plot$layers, function(l) inherits(l$stat, "StatDenLast"),
                                 logical(1)))
  add_labels <- !isFALSE(object$last_label) && length(line_layers) > 0 && !already_labelled

  x_info <- den_x_info(plot)
  add_scale <- !isFALSE(object$date_breaks) && !is.na(x_info$class) &&
    !plot$scales$has_scale("x")

  if (add_scale) {
    by <- if (is.character(object$date_breaks)) object$date_breaks else NULL
    scale_fun <- if (x_info$class == "Date") ggplot2::scale_x_date else ggplot2::scale_x_datetime
    right <- if (add_labels) 0.10 else 0.02
    plot <- plot + scale_fun(breaks = breaks_from_last(x_info$last, by = by),
                             labels = label_from_last,
                             expand = ggplot2::expansion(mult = c(0.02, right)))
  }

  if (add_labels) {
    for (l in line_layers) {
      extra <- if (is.null(object$last_label$colour) && !is.null(l$aes_params$colour)) {
        list(colour = l$aes_params$colour)
      } else {
        list()
      }
      data <- if (is.data.frame(l$data) || is.function(l$data)) l$data else NULL
      plot <- plot + last_label_layer(l$mapping, data, l$inherit.aes, object$last_label,
                                      base_size = object$base_size, extra_params = extra)
    }
    # Our date scale expands the right side of a single panel enough for the
    # labels. Otherwise (no such scale, or narrow facet panels) let labels
    # run past the panel edge into extra right-hand space.
    facetted <- !inherits(plot$facet, "FacetNull")
    if (!add_scale || facetted) plot <- make_label_room(plot, object, facetted)
  }

  plot
}

is_line_layer <- function(layer) {
  (inherits(layer$geom, "GeomLine") || inherits(layer$geom, "GeomPath")) &&
    inherits(layer$stat, "StatIdentity")
}

make_label_room <- function(plot, object, facetted = FALSE) {
  if (isTRUE(plot$coordinates$default) || is.null(plot$coordinates$clip)) {
    plot <- plot + ggplot2::coord_cartesian(clip = "off", default = TRUE)
  } else if (inherits(plot$coordinates, "CoordCartesian") && !inherits(plot$coordinates, "CoordFlip")) {
    plot$coordinates <- ggplot2::ggproto(NULL, plot$coordinates, clip = "off")
  }
  room <- object$base_size * 3
  half_line <- object$base_size / 2
  if (facetted) plot <- plot + ggplot2::theme(panel.spacing.x = ggplot2::unit(room, "pt"))
  if (identical(object$legend_position, "right")) {
    plot + ggplot2::theme(legend.box.spacing = ggplot2::unit(room, "pt"))
  } else {
    plot + ggplot2::theme(plot.margin = ggplot2::margin(half_line, room, half_line, half_line))
  }
}

# Class of the x variable across all layers ("Date", "POSIXct", or NA when x
# is anything else, mixed, or cannot be evaluated) and its last value.
den_x_info <- function(plot) {
  plot_x <- plot$mapping$x
  values <- list()
  if (!is.null(plot_x) && is.data.frame(plot$data)) {
    values <- c(values, list(x_value(plot_x, plot$data)))
  }
  for (l in plot$layers) {
    x <- l$mapping$x %||% if (isTRUE(l$inherit.aes)) plot_x
    if (is.null(x)) next
    data <- tryCatch(l$layer_data(plot$data), error = function(e) NULL)
    values <- c(values, list(x_value(x, data)))
  }
  classes <- unique(vapply(values, function(v) {
    if (inherits(v, "Date")) "Date" else if (inherits(v, "POSIXct")) "POSIXct" else "other"
  }, character(1)))
  if (length(classes) != 1 || !classes %in% c("Date", "POSIXct")) {
    return(list(class = NA_character_, last = NULL))
  }
  list(class = classes, last = max(do.call(c, values), na.rm = TRUE))
}

x_value <- function(quo, data) {
  if (!is.data.frame(data) || is_calculated_x(quo)) return(NULL)
  tryCatch(rlang::eval_tidy(quo, data), error = function(e) NULL)
}

is_calculated_x <- function(quo) {
  expr <- rlang::quo_get_expr(quo)
  is.call(expr) && as.character(expr[[1]])[length(as.character(expr[[1]]))] %in%
    c("after_stat", "after_scale", "stage", "stat")
}
