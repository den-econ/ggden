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

ggplot(mtcars, aes(wt, mpg, colour = factor(cyl))) +
  geom_point(size = 3) +
  scale_color_den() +
  theme_den() +
  labs(title = "Example Plot")
# den_save("fig.png")
```

## Functions

| Function | Purpose |
|---|---|
| `theme_den()` | DEN house-style theme |
| `scale_color_den()` | Discrete colour scale |
| `scale_fill_den()` | Discrete fill scale |
| `den_color(i)` | Get the *i*-th palette colour (1-based, matches Stata `den1`–`den12`) |
| `den_palette(n)` | Get first *n* palette colours |
| `den_colors` | Named colour vector |
| `den_save()` | Save at 300 dpi |

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

