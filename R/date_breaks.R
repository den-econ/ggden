#' Date breaks anchored at the last observation
#'
#' Returns a breaks function for \code{\link[ggplot2]{scale_x_date}} or
#' \code{\link[ggplot2]{scale_x_datetime}} whose last tick is the last
#' observation (the upper scale limit). The remaining ticks step backward
#' from there at a regular interval.
#'
#' ggplot2 passes the \emph{expanded} axis range to a breaks function, so
#' when used by hand, supply the last observation through \code{last}.
#' \code{theme_den()} does this automatically.
#'
#' @param last The last observation (a \code{Date} or \code{POSIXct}),
#'   usually \code{max(df$date)}. \code{NULL} (default) falls back to the
#'   upper axis limit, which includes the axis expansion.
#' @param n Approximate maximum number of breaks when \code{by} is
#'   \code{NULL} (default 6).
#' @param by Step between breaks, as accepted by \code{\link[base]{seq.Date}}:
#'   e.g. \code{"1 year"}, \code{"6 months"}, \code{"3 months"},
#'   \code{"2 weeks"}. \code{NULL} (default) chooses a step from the range.
#' @return A function mapping scale limits to a vector of breaks.
#' @export
#' @examples
#' library(ggplot2)
#' df <- data.frame(
#'   date  = seq(as.Date("2018-08-01"), as.Date("2026-08-01"), by = "month"),
#'   value = cumsum(rnorm(97))
#' )
#' ggplot(df, aes(date, value)) +
#'   geom_line() +
#'   scale_x_date(breaks = breaks_from_last(max(df$date), by = "2 years"),
#'                labels = scales::label_date("%b %Y"))
breaks_from_last <- function(last = NULL, n = 6, by = NULL) {
  force(last)
  force(n)
  force(by)
  function(limits) {
    if (length(limits) < 2 || anyNA(limits)) return(NULL)
    first <- min(limits)
    last  <- if (is.null(last)) max(limits) else as_like(last, limits)
    if (first >= last) return(last)
    step <- by %||% auto_date_step(first, last, n)
    seq_backward(first, last, step)
  }
}

# Coerce `x` to the class of the scale limits (Date or POSIXct).
as_like <- function(x, limits) {
  if (inherits(limits, "Date")) return(as.Date(x))
  if (inherits(limits, "POSIXct")) return(as.POSIXct(x, tz = attr(limits, "tzone") %||% ""))
  x
}

# Steps tried in order; the first giving at most n breaks is used.
date_steps <- c(
  "1 sec" = 1 / 86400, "15 secs" = 15 / 86400, "1 min" = 1 / 1440,
  "15 mins" = 15 / 1440, "1 hour" = 1 / 24, "3 hours" = 3 / 24,
  "6 hours" = 6 / 24, "12 hours" = 12 / 24,
  "1 day" = 1, "2 days" = 2, "1 week" = 7, "2 weeks" = 14,
  "1 month" = 30.44, "2 months" = 60.88, "3 months" = 91.31,
  "6 months" = 182.62, "1 year" = 365.25, "2 years" = 730.5,
  "5 years" = 1826.25, "10 years" = 3652.5, "20 years" = 7305,
  "25 years" = 9131.25, "50 years" = 18262.5, "100 years" = 36525
)

auto_date_step <- function(first, last, n) {
  span <- as.numeric(difftime(last, first, units = "days"))
  steps <- if (inherits(last, "Date")) date_steps[date_steps >= 1] else date_steps
  fits <- span / steps < n
  if (!any(fits)) return(names(steps)[length(steps)])
  names(steps)[which(fits)[1]]
}

# seq(last, first, by = "-<step>"), returned in ascending order. Month-based
# steps from a day > 28 are built on month ends so that e.g. 31 Aug steps
# back to 31 May rather than overflowing into the following month.
seq_backward <- function(first, last, step) {
  parts <- strsplit(trimws(step), "\\s+")[[1]]
  k    <- if (length(parts) == 2) as.integer(parts[1]) else 1L
  unit <- parts[length(parts)]
  monthly <- grepl("^(month|quarter|year)", unit)

  if (inherits(last, "Date") && monthly && as.integer(format(last, "%d")) > 28) {
    day <- as.integer(format(last, "%d"))
    month_start <- as.Date(format(last, "%Y-%m-01"))
    n_steps <- ceiling(as.numeric(last - first) / 28) + 1
    starts <- seq(month_start, by = paste(-k, unit), length.out = n_steps)
    next_starts <- as.Date(vapply(
      starts, function(s) as.numeric(seq(s, by = "month", length.out = 2)[2]), numeric(1)
    ), origin = "1970-01-01")
    month_len <- as.integer(format(next_starts - 1, "%d"))
    out <- starts + pmin(day, month_len) - 1
    return(rev(out[out >= first]))
  }

  rev(seq(last, first, by = paste(-k, unit)))
}

# Label function matched to the spacing of the breaks.
label_from_last <- function(breaks) {
  breaks <- breaks[!is.na(breaks)]
  if (length(breaks) == 0) return(character())
  spacing <- if (length(breaks) > 1) {
    stats::median(as.numeric(diff(breaks), units = "days"))
  } else {
    365
  }
  fmt <- if (spacing >= 360 && all(format(breaks, "%m-%d") == "01-01")) {
    "%Y"
  } else if (spacing >= 28) {
    "%b %Y"
  } else if (spacing >= 1) {
    "%d %b %Y"
  } else {
    "%d %b %H:%M"
  }
  format(breaks, fmt)
}
