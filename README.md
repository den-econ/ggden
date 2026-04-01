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

