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
```

## Functions

| Function | Purpose |
|---|---|
| `theme_den()` | DEN house-style theme |
| `scale_color_den()` | Discrete colour scale |
| `scale_fill_den()` | Discrete fill scale |
| `den_palette(n)` | Get first n palette colours |
| `den_colors` | Named colour vector |
| `den_save()` | Save at 300 dpi |

## Documentation

See `demo.qmd` for a full walkthrough with all chart types — render it with:

```bash
quarto render demo.qmd
```
