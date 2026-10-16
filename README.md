# Laboratory Cohort Assays for Grapevine Resistance to Vine Mealybug (*Planococcus ficus*)

Analysis code and processed data accompanying:

> Dashner ZS, Uchima SY, Sisterson MS, and Riaz S. Laboratory cohort assays as a tool to evaluate grapevine germplasm for resistance to vine mealybug (*Planococcus ficus*). *American Journal of Enology and Viticulture*. (in review)

USDA-ARS, San Joaquin Valley Agricultural Center, Parlier, CA

---

## What this repository contains

A reproducible analysis of three assays used to phenotype grapevine germplasm for resistance to vine mealybug (VMB):

1. **12-day no-choice assay** across 15 *Vitis* and *Muscadinia* accessions — VMB establishment (recovery) and development (body area).
2. **6-week life-cycle assay** comparing *M. rotundifolia* Barrett Mn-1 against the reference susceptible rootstock Freedom — survival, growth, and reproduction.
3. **Two-choice assay** testing behavioral preference between the two reference accessions.

Simulation-based power analyses for all three designs are included, and produce the replication recommendations reported in the manuscript.

## Requirements

- **R** 4.6.0 ([download](https://cran.r-project.org/)) — the version pinned in `renv.lock`
- **RStudio** ≥ 2023.06 recommended (the `.Rproj` file sets the working directory automatically)
- Roughly 2 GB of RAM and a few minutes of runtime; the power-analysis chunks are the slow part (1,000 simulations per design)

## How to run it

The analysis uses **project-relative paths only** — there are no hardcoded directories, so it runs from wherever you put it.

```bash
git clone https://github.com/Zachary-Dashner-USDA-ARS/VMB_Resistance_Screening.git
cd VMB_Resistance_Screening
```

Then:

1. Open `VMB_Resistance_Screening.Rproj` in RStudio. This sets the working directory to the project root.
2. Restore the package environment:

   ```r
   install.packages("renv")   # if you don't already have it
   renv::restore()            # installs the exact package versions used for the manuscript
   ```

   If you would rather not use `renv`, install the packages listed in [Packages](#packages) manually.
3. Open `analysis/01_VMB_resistance_analysis.Rmd` and run all chunks, or knit it.

The setup chunk calls `here::i_am()` and sets the knitr root directory to the project root, so every chunk runs from the top level regardless of where the `.Rmd` lives. **You do not need to edit any paths.**

Outputs are written to `figures/` and `results/`. Both directories are created automatically if missing.

### Running outside RStudio

```r
install.packages("here")
rmarkdown::render("analysis/01_VMB_resistance_analysis.Rmd")
```

`here` locates the project root by finding the `.Rproj` file, so this works from any working directory.

## Project structure

```
VMB_Resistance_Screening/
├── analysis/
│   ├── 00_session_info.R                # records R and package versions
│   ├── 01_VMB_resistance_analysis.Rmd   # canonical analysis — all reported statistics and figures
│   └── 02_verify_results.R              # checks reported values against model output
├── data/
│   ├── processed/
│   │   └── AJEV_VMB_AllData.xlsx        # analysis-ready data, one sheet per assay (see below)
│   ├── raw/                             # original per-assay collection files (not tracked; see Data availability)
│   └── reference/
│       └── VMB_Size_Conversion_corrected.xlsx  # size-gradation template (Supplemental Table 2)
├── figures/
│   ├── published/                       # figures exactly as submitted to AJEV
│   └── ...                              # regenerated figures (gitignored)
├── results/                             # cached power grids (.rds), session_info.txt,
│                                       #   package_citations.txt
├── VMB_Resistance_Screening.Rproj
├── renv.lock                            # exact package versions
└── README.md
```

### Data

All analyses read from a single workbook, `data/processed/AJEV_VMB_AllData.xlsx`:

| Sheet | Contents |
|---|---|
| `VMB_Sizes` | Size-gradation template mapping length × width to body area (mm²) |
| `VMB9_combined_df` | 12-day no-choice assay, 15 accessions |
| `VMB_Crawler_combined_df` | 6-week life-cycle assay |
| `VMB8` | Follow-up 12-day no-choice assay, experiment 2 |
| `VMB7_final` | Follow-up 12-day no-choice assay, experiment 1 |
| `VMB_choice` | Two-choice assay |

**Data availability.** The full datasets have been deposited in the USDA National Agricultural Library's Ag Data Commons and will be publicly available at [DOI:10.15482/USDA.ADC/32592282](https://doi.org/10.15482/USDA.ADC/32592282) on release from curatorial review. Cite the Ag Data Commons DOI for the data; cite this repository for the code.

### How body area was measured

VMB length and width were read against a 44-step size-gradation template (`data/reference/VMB_Size_Conversion_corrected.xlsx`, reproduced as Supplemental Table 2 in the manuscript) under a dissecting microscope. Body area is the product of the matched length and width values. The template is the measurement instrument, not a post hoc classification — every mm² value in the figures derives from it.

## Packages

Fitting: `lme4`, `lmerTest`, `glmmTMB`, `mgcv`
Inference: `emmeans`, `multcomp`, `multcompView`, `car`, `DHARMa`, `binom`
Data and plotting: `tidyverse` (`dplyr`, `tidyr`, `ggplot2`, `forcats`, `purrr`, `tibble`), `readxl`, `writexl`, `patchwork`, `cowplot`, `ggpubr`, `ggsignif`, `ggtext`, `gridExtra`
Infrastructure: `here`, `renv`

Exact versions are pinned in `renv.lock`. To print the versions used for a given run:

```r
devtools::session_info()
```

## Reproducing specific manuscript results

| Manuscript element | Where in the notebook |
|---|---|
| Figure 1A–D, 12-day assay statistics | `model_area_VMB9_initial`, `model_recovery_VMB9`, `m_area_interaction`, `m_recovery_main_789` |
| Figure 2A–C, 6-week life cycle | `m_surv_binom2`, `m_area_gamma_RE` |
| Figure 3A–B, reproduction | `m_repro_prop`, `m_repro_count` |
| Figure 4, choice assay | `m_choice_bb` (arena-level beta-binomial) |
| Figure 5A–C, power analyses | simulation chunks; cached to `results/*.rds` |
| Run-variation sensitivity (not in the manuscript) | `power_growth_sens`, `power_choice_sens` |

The unit of replication throughout is the **cage**. In the 12-day assay, five VMB were introduced per cage and measured individually before and after the assay, but individuals were not marked and therefore not tracked. Initial size accordingly enters the models as a cage-level mean (`InitialMean`), with cage fitted as a random intercept.

## Verifying the reported values

After running the notebook, in the same session:

```r
source(here::here("analysis", "02_verify_results.R"))
```

This checks 26 values against the numbers reported in the manuscript — sample sizes, model
coefficients, test statistics, and the Type I error calibration underlying Figure 5 —
and prints a pass/fail table. Every expected value is hard-coded from the manuscript text, so
the script fails if the code and the paper ever disagree.

## License and citation

Work produced by USDA-ARS employees in the course of their official duties is in the public domain within the United States.

If you use this code, please cite the manuscript above and this repository.

## Contact

Zachary S. Dashner — USDA-ARS, San Joaquin Valley Agricultural Center
Corresponding author: Summaira Riaz — summaira.riaz@usda.gov
