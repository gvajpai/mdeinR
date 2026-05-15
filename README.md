<img src="inst/figures/logo.png" align="right" height="200"/>

# mdeinR

> **Memorable Dining Experience (MDE) text analysis for restaurant reviews**

<!-- badges: start -->
[![R-CMD-check](https://github.com/gvajpai/mdeinR/workflows/R-CMD-check/badge.svg)](https://github.com/gvajpai/mdeinR/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![DOI](https://zenodo.org/badge/1233502170.svg)](https://doi.org/10.5281/zenodo.20215048)
<!-- badges: end -->

`mdeinR` scores the five dimensions of the Memorable Dining Experience
(MDE) framework from free-text restaurant reviews using a theoretically
grounded, validated lexicon of 324 words.

| Dimension | Description | Words |
|-----------|-------------|------:|
| **sensory** | Sight, sound, taste, smell, touch; food quality, ambience, décor | 85 |
| **affect** | Emotions and psychological reactions aroused during dining | 82 |
| **social** | Feelings of belonging; interactions with staff, friends, family | 58 |
| **intellectual** | Curiosity, learning, cognitive engagement | 51 |
| **behavioral** | Physical engagement, activities, involvement | 48 |

The package implements sentence-level MDE scoring with valence-shifter
adjustment (negator / amplifier / de-amplifier / adversative conjunction),
a built-in sentence tokeniser, and a bundled valence-shifter table — all
without external NLP dependencies. The scoring algorithm is inspired by
[sentimentr](https://github.com/trinker/sentimentr) by Tyler W. Rinker.

---

## Installation

```r
# Install devtools if needed
# install.packages("devtools")

devtools::install_github("gvajpai/mdeinR")
```

After cloning or installing, build the data objects once:

```r
source("data-raw/build_dictionary.R")
```

### Dependencies

`mdeinR` only requires:

| Package | Role |
|---------|------|
| [data.table](https://rdatatable.gitlab.io/data.table/) | Fast in-memory operations |
| [stringi](https://stringi.gagolewski.com/) | String tokenisation |

No external NLP package is required.

---

## Quick start

```r
library(mdeinR)

reviews <- c(
  "The aroma and presentation were absolutely stunning, a feast for the senses.",
  "Staff were warm and genuinely caring — we truly felt at home.",
  "We discovered exotic spices and learned about the history of Moroccan cuisine.",
  "Nothing particularly noteworthy about the food or the décor."
)

# --- Sentence-level scores ---
mde(reviews)

# --- Aggregate over the whole corpus ---
mde_by(reviews)

# --- Group by restaurant ---
library(data.table)
df <- data.table(
  restaurant = c("A", "A", "B", "B"),
  text = c(
    "The aroma was stunning.",
    "Staff were so caring and warm.",
    "Very educational — we tried exotic dishes.",
    "Plain and forgettable food."
  )
)
mde_by(df, by = "restaurant")

# --- Annotate a single review ---
highlight_mde("The aroma was wonderful and staff were so caring.")
```

---

## Algorithm

For each sentence:

1. Tokenise to lower-case words; count *n* words.
2. For each token matching the MDE dictionary, assign raw score `1 / n`
   to the matched dimension.
3. Examine a context window (`n.before = 5`, `n.after = 2`) for
   valence shifters from `mdeinR::valence_shifters`:
   - **Negator** (type 1): multiply score by `−1`
   - **Amplifier** (type 2): multiply by `1 + amplifier.weight` (default 0.8)
   - **De-amplifier** (type 3): multiply by `1 − n.neutral` (default 0.2)
   - **Adversative** (type 4): words after the conjunction receive reduced weight
4. Per MDE theory, negated (negative) scores are set to zero — only
   positive occurrences count.
5. Dimension scores are summed across the sentence.

`mde_by()` averages sentence-level scores within each group.

---

## Citation

If you use `mdeinR` in published research, please cite both the paper and the software:

**Paper (lexicon and methodology):**

> Vajpai, G. N., Webb, T., & Beldona, S. (2025). Designing a memorable
> dining experience lexicon based on theory and text mining.
> *International Journal of Hospitality Management*, 130, 104245.
> <https://doi.org/10.1016/j.ijhm.2025.104245>

**Software:**

> Vajpai, G. N., Webb, T., & Beldona, S. (2026). mdeinR: Memorable
> Dining Experience Text Analysis (v0.2.0). Zenodo.
> <https://doi.org/10.5281/zenodo.20215048>

BibTeX:

```bibtex
@article{vajpai2025mde,
  title   = {Designing a memorable dining experience lexicon based on
             theory and text mining},
  author  = {Vajpai, Gopi Nath and Webb, Timothy and Beldona, Srikanth},
  journal = {International Journal of Hospitality Management},
  volume  = {130},
  pages   = {104245},
  year    = {2025},
  doi     = {10.1016/j.ijhm.2025.104245}
}

@software{vajpai2026mdeinR,
  title   = {{mdeinR}: Memorable Dining Experience Text Analysis},
  author  = {Vajpai, Gopi Nath and Webb, Timothy and Beldona, Srikanth},
  year    = {2026},
  version = {0.2.0},
  doi     = {10.5281/zenodo.20215048},
  url     = {https://github.com/gvajpai/mdeinR}
}
```

---

## License

MIT © 2025 Gopi Nath Vajpai, Timothy Webb, Srikanth Beldona

Portions of this package — specifically the sentence-level scoring algorithm,
the valence-shifter parameter design, and the valence-shifter token lists —
are derived from **sentimentr** by Tyler W. Rinker (MIT © 2017). Full
derived-work notices are in [`LICENSE.md`](LICENSE.md).
