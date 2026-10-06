#' Options for last-value labels
#'
#' Builds the label specification used by \code{theme_den(last_label = ...)}
#' and \code{geom_last_label()}. Labels are drawn at the last observation
#' (largest x) of each line, in the same colour as the line.
#'
#' @param format Function turning the numeric value into text
#'   (default \code{scales::label_number(accuracy = 0.1, big.mark = ",")}). Any
#'   \pkg{scales} labeller works, e.g.
#'   \code{scales::label_percent(accuracy = 0.1, scale = 1)}.
#' @param size Text size in mm. \code{NULL} (default) matches the axis text
#'   of \code{theme_den()}.
#' @param fontface Font face (default \code{"bold"}).
#' @param colour Fixed label colour. \code{NULL} (default) uses the colour
#'   of the line.
#' @param dodge Minimum vertical gap between labels in the same panel, as a
#'   fraction of the y range. Labels closer than this are pushed apart;
#'   \code{0} or \code{FALSE} disables it. Default \code{0.045}.
#' @param repel If \code{TRUE}, use \code{ggrepel::geom_text_repel()}
#'   instead of the built-in dodge (requires \pkg{ggrepel}).
#' @return A \code{den_last_label} object.
#' @export
#' @examples
#' den_last_label(format = scales::label_percent(accuracy = 0.1, scale = 1))
den_last_label <- function(format = scales::label_number(accuracy = 0.1, big.mark = ","),
                           size = NULL, fontface = "bold", colour = NULL,
                           dodge = 0.045, repel = FALSE) {
  if (!is.function(format)) stop("`format` must be a function.", call. = FALSE)
  if (isTRUE(repel) && !requireNamespace("ggrepel", quietly = TRUE)) {
    stop("`repel = TRUE` requires the ggrepel package.", call. = FALSE)
  }
  structure(
    list(format = format, size = size, fontface = fontface, colour = colour,
         dodge = as.numeric(dodge), repel = isTRUE(repel)),
    class = "den_last_label"
  )
}

#' Label the last value of each line
#'
#' Adds a text label at the last observation of each group, coloured like
#' the line. \code{theme_den()} adds this automatically for line layers
#' that precede it; use \code{geom_last_label()} for lines added after
#' \code{theme_den()} or for full control.
#'
#' @param mapping,data,inherit.aes As in \code{\link[ggplot2]{geom_text}}.
#' @param label A \code{\link{den_last_label}} specification.
#' @param ... Other fixed aesthetics passed to the layer
#'   (e.g. \code{colour = "black"}).
#' @return A ggplot2 layer.
#' @export
#' @examples
#' library(ggplot2)
#' df <- data.frame(t = rep(1:10, 2), y = c(1:10, 10:1), g = rep(c("a", "b"), each = 10))
#' ggplot(df, aes(t, y, colour = g)) +
#'   geom_line() +
#'   geom_last_label() +
#'   theme_den()
geom_last_label <- function(mapping = NULL, data = NULL, label = den_last_label(),
                            inherit.aes = TRUE, ...) {
  last_label_layer(mapping, data, inherit.aes, label, extra_params = list(...))
}

StatDenLast <- ggplot2::ggproto("StatDenLast", ggplot2::Stat,
  required_aes = c("x", "y"),

  compute_panel = function(data, scales, format = scales::label_number(accuracy = 0.1, big.mark = ","),
                           dodge = 0) {
    data <- data[!is.na(data$x) & !is.na(data$y), , drop = FALSE]
    if (nrow(data) == 0) return(data)
    last <- do.call(rbind, lapply(split(data, data$group), function(d) {
      d[which.max(d$x), , drop = FALSE]
    }))
    last$label <- paste0(" ", format(untransform_y(last$y, scales$y)))
    if (dodge > 0 && nrow(last) > 1) {
      last$y <- dodge_positions(last$y, gap = dodge * diff(range(scales$y$dimension())))
    }
    last
  }
)

untransform_y <- function(y, scale) {
  if (is.null(scale) || !is.function(scale$get_transformation)) return(y)
  scale$get_transformation()$inverse(y)
}

# Spread values so that neighbours are at least `gap` apart. Overlapping
# labels are merged into clusters centred on the mean of their true values.
dodge_positions <- function(y, gap) {
  if (!is.finite(gap) || gap <= 0) return(y)
  ord <- order(y)
  ys <- y[ord]
  clusters <- lapply(seq_along(ys), function(i) i)
  place <- function(members) {
    mean(ys[members]) + (seq_along(members) - (length(members) + 1) / 2) * gap
  }
  repeat {
    pos <- lapply(clusters, place)
    hit <- which(vapply(seq_len(length(clusters) - 1), function(i) {
      max(pos[[i]]) + gap > min(pos[[i + 1]]) + 1e-9
    }, logical(1)))
    if (length(hit) == 0) break
    i <- hit[1]
    clusters[[i]] <- c(clusters[[i]], clusters[[i + 1]])
    clusters[[i + 1]] <- NULL
  }
  out <- numeric(length(y))
  out[ord] <- unlist(lapply(clusters, place))
  out
}

# Build the label layer. `mapping` is reduced to aesthetics text can use;
# a dropped discrete aesthetic (e.g. linetype) is kept as the group.
last_label_layer <- function(mapping, data, inherit.aes, label, base_size = 12,
                             extra_params = list()) {
  geom <- if (label$repel) ggrepel::GeomTextRepel else ggplot2::GeomText
  if (!is.null(mapping)) {
    keep <- names(mapping) %in% c(geom$aesthetics(), "group")
    dropped <- mapping[!keep]
    mapping <- mapping[keep]
    if (is.null(mapping$group) && length(dropped) > 0) mapping$group <- dropped[[1]]
    class(mapping) <- class(ggplot2::aes())
  }

  params <- list(
    format = label$format,
    dodge = if (label$repel) 0 else label$dodge,
    size = label$size %||% (base_size * 0.85 / ggplot2::.pt),
    fontface = label$fontface,
    hjust = -0.1,
    na.rm = TRUE
  )
  if (label$repel) {
    params <- c(params, list(direction = "y", min.segment.length = Inf,
                             box.padding = 0.1, xlim = c(NA, Inf)))
  }
  if (!is.null(label$colour)) params$colour <- label$colour
  params[names(extra_params)] <- extra_params

  ggplot2::layer(
    geom = geom, stat = StatDenLast, data = data, mapping = mapping,
    position = "identity", show.legend = FALSE, inherit.aes = inherit.aes,
    params = params
  )
}
