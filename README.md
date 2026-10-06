# ggden <img src="man/figures/logo.png" align="right" height="139" />

A ggplot2 theme and colour palettes for **Dewan Ekonomi Nasional (DEN)**.

## Installation

```r
# install.packages("remotes")
# you can also use "devtools"
remotes::install_github("den-econ/ggden")
```

## Quick Start

```r
library(ggden)
library(ggplot2)

set.seed(1)
dates <- seq(as.Date("2018-08-01"), as.Date("2026-08-01"), by = "month")
df <- data.frame(
  date   = rep(dates, 2),
  series = rep(c("Inflasi", "BI Rate"), each = length(dates)),
  value  = c(cumsum(rnorm(length(dates), 0, 0.2)) + 3,
             cumsum(rnorm(length(dates), 0, 0.1)) + 5)
)

ggplot(df, aes(date, value, colour = series)) +
  geom_line(linewidth = 1) +
  scale_color_den() +
  theme_den() +
  labs(title = "Example Plot", x = NULL, y = "%")
# den_save("fig.png")
```

This gives a gridless chart with the last value of each line labelled in
the line's colour, and x ticks at Aug 2018, Aug 2020, …, Aug 2026, anchored
at the last observation.

`theme_den()` works on any ggplot. For a chart without lines and without a
date x-axis, such as a scatter plot, it only applies the styling:

```r
ggplot(mtcars, aes(wt, mpg, colour = factor(cyl))) +
  geom_point(size = 3) +
  scale_color_den() +
  theme_den()
```

## Functions

| Function | Purpose |
|---|---|
| `theme_den()` | DEN house style, with last-value labels and date ticks anchored at the last observation |
| `theme_den_base()` | Styling only, as a plain theme object, e.g. for `theme_set()` |
| `den_last_label()` | Customise last-value labels |
| `geom_last_label()` | Add last-value labels by hand |
| `breaks_from_last()` | Date breaks anchored at the last observation, for your own `scale_x_date()` |
| `scale_color_den()` | Discrete colour scale |
| `scale_fill_den()` | Discrete fill scale |
| `den_color(i)` | Get the *i*-th palette colour (1-based, matches Stata `den1`–`den12`) |
| `den_palette(n)` | Get first *n* palette colours |
| `den_colors` | Named colour vector |
| `den_supplementary` | Named vector of 16 supplementary colours |
| `den_save()` | Save at 300 dpi |

## Default behaviour of `theme_den()`

```r
theme_den(base_size = 12, base_family = "sans", legend_position = "top",
          last_label = TRUE, date_breaks = TRUE)
```

1. **No grid lines.** Only the left and bottom axis lines are drawn.
2. **Last-value labels.** Every `geom_line()`, `geom_step()` and `geom_path()`
   layer gets a bold label at its last observation (largest x), coloured like
   the line, including lines with a fixed colour such as
   `geom_line(colour = "red")`. Labels of the same layer that would overlap
   are pushed apart vertically; labels from different layers (e.g. an actual
   series and a separate trend-line layer) are not, so use one layer with a
   `colour` mapping, `repel = TRUE`, or `last_label = FALSE` there. In
   facetted plots, each panel is labelled separately.
3. **Date ticks anchored at the last observation.** When x is a `Date` or
   `POSIXct`, the last tick is the last observation and the other ticks step
   backward from it at a regular interval. This only happens when:
   - every layer's x is a `Date` (or every one is a `POSIXct`), and
   - you have not set an x scale yourself.

   Otherwise ggplot2's default ticks are kept: for numeric years
   (`Tahun = 2015:2024`), factors, text, scatter plots, and any plot where you
   added `scale_x_date()` / `scale_x_continuous()`.

**Add `theme_den()` after your geoms.** It only sees the layers already in
the plot, and it is usually the last line anyway. For a line added after
`theme_den()`, use `geom_last_label()`.

`theme_den()` returns a special object rather than a plain theme, so use
`theme_den_base()` where a theme object is required:

```r
theme_set(theme_den_base())
```

## Last-value labels (`last_label`)

```r
p <- ggplot(df, aes(date, value, colour = series)) + geom_line()

# On (default): one decimal, bold, same colour as the line
p + theme_den()

# Off
p + theme_den(last_label = FALSE)

# Number format only: pass any scales labeller as a function
p + theme_den(last_label = scales::label_percent(accuracy = 0.1, scale = 1))  # "5.1%"
p + theme_den(last_label = scales::label_comma(accuracy = 1))                 # "15,230"

# Full control
p + theme_den(last_label = den_last_label(
  format   = scales::label_number(accuracy = 0.01, suffix = " pp"),
  size     = 4,
  fontface = "plain",
  colour   = "grey20",   # one colour for all labels instead of the line colour
  dodge    = 0.06        # larger minimum gap between labels
))

# Use ggrepel instead of the built-in dodge (needs install.packages("ggrepel"))
p + theme_den(last_label = den_last_label(repel = TRUE))

# By hand, e.g. for a line added after theme_den()
p + theme_den() + geom_line(aes(y = value * 1.1), linetype = "dashed") +
  geom_last_label(aes(y = value * 1.1))
```

`den_last_label()` arguments:

| Argument | Default | Meaning |
|---|---|---|
| `format` | `scales::label_number(accuracy = 0.1, big.mark = ",")` | Function turning the value into text |
| `size` | `NULL` (same size as axis text) | Text size in mm |
| `fontface` | `"bold"` | `"plain"`, `"bold"`, `"italic"`, `"bold.italic"` |
| `colour` | `NULL` (line colour) | Fixed colour for all labels |
| `dodge` | `0.045` | Minimum vertical gap between labels as a fraction of the y range; `0` turns dodging off |
| `repel` | `FALSE` | Use `ggrepel::geom_text_repel()` instead |

The label shows the value of the last data point. To label a different
quantity (e.g. the latest year-on-year change), compute it in the data first.

## Date ticks (`date_breaks`)

```r
# Default: automatic step, last tick = last observation
p + theme_den()                         # Aug 2018, Aug 2020, ..., Aug 2026

# Fixed step
p + theme_den(date_breaks = "1 year")   # Aug 2018, Aug 2019, ..., Aug 2026
p + theme_den(date_breaks = "6 months") # ..., Feb 2026, Aug 2026

# Off: ggplot2's default ticks (Jan 2020, Jan 2022, ...)
p + theme_den(date_breaks = FALSE)

# Your own scale always wins; use breaks_from_last() to keep the anchoring
p + scale_x_date(breaks = breaks_from_last(max(df$date), by = "2 years"),
                 labels = scales::label_date("%b %y")) +
  theme_den()
```

Tick labels follow the step: `%Y` for yearly ticks on 1 January, `%b %Y` for
monthly to yearly ticks, `%d %b %Y` for daily or weekly ticks. Month-end data
stays on month ends, e.g. 31 Aug 2026 → 28 Feb 2026 → 31 Aug 2025.

A numeric year column is not a date, so its ticks are left alone. To get
anchored ticks, convert it, e.g. `as.Date(paste0(Tahun, "-01-01"))`.

## Picking colours by position

Use `den_color(i)` to select a specific palette colour by position (1-based):

```r
den_color(1)   # "#EEC051" (gold)
den_color(3)   # "#C00000" (red)

# Use in ggplot
ggplot(df, aes(x, y)) +
  geom_point(color = den_color(1)) +
  geom_line(color = den_color(3)) +
  theme_den()

# Override colours in grouped plots
ggplot(df, aes(x, y, color = group)) +
  geom_point() +
  scale_color_manual(values = c(
    "A" = den_color(1),
    "B" = den_color(3)
  )) +
  theme_den()
```

Or access by name with `den_colors`:

```r
den_colors["gold"]        # "#EEC051"
den_colors["dark_brown"]  # "#845B24"
den_colors["red"]         # "#C00000"
```

## Supplementary colours (manual use)

16 additional colours from the DEN PPT template and team preferences. These are **not** part of the auto-cycled palette — access them by name via `den_supplementary`.

| Pos | Name | Accessor | Hex |
|-----|------|----------|-----|
| 13 | Cream | `den_supplementary["cream"]` | `#FBEEC9` |
| 14 | Amber Gold | `den_supplementary["amber_gold"]` | `#F0A22E` |
| 15 | Ochre | `den_supplementary["ochre"]` | `#C87D0E` |
| 16 | Burnt Orange | `den_supplementary["burnt_orange"]` | `#C17529` |
| 17 | Raw Amber | `den_supplementary["raw_amber"]` | `#91581F` |
| 18 | Sand | `den_supplementary["sand"]` | `#C3986D` |
| 19 | Caramel | `den_supplementary["caramel"]` | `#A27242` |
| 20 | Clay | `den_supplementary["clay"]` | `#A5644E` |
| 21 | Chocolate | `den_supplementary["chocolate"]` | `#7C4B3B` |
| 22 | Espresso | `den_supplementary["espresso"]` | `#4E3B30` |
| 23 | Dark Red | `den_supplementary["dark_red"]` | `#820000` |
| 24 | Rose Brown | `den_supplementary["rose_brown"]` | `#B58B80` |
| 25 | Olive | `den_supplementary["olive"]` | `#7C7154` |
| 26 | Medium Grey | `den_supplementary["medium_grey"]` | `#7F7F7F` |
| 27 | Steel | `den_supplementary["steel"]` | `#70848F` |
| 28 | Navy Slate | `den_supplementary["navy_slate"]` | `#3E5064` |

**Usage:**

```r
# Override specific colours in grouped plots
ggplot(df, aes(x, y, color = group)) +
  geom_point() +
  scale_color_manual(values = c(
    "Group A" = den_colors["gold"],
    "Group B" = den_supplementary["dark_red"],
    "Group C" = den_supplementary["navy_slate"]
  )) +
  theme_den()

# Use directly in geom aesthetics
ggplot(df, aes(x, y)) +
  geom_point(color = den_supplementary["steel"]) +
  geom_line(color = den_supplementary["burnt_orange"]) +
  theme_den()
```

