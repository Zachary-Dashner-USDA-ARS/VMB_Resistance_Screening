# Raw data

Original per-assay collection files. These are **not tracked in git** — they are
permanently archived at the USDA Ag Data Commons:

**DOI:10.15482/USDA.ADC/32592282** — https://doi.org/10.15482/USDA.ADC/32592282

The analysis in `analysis/01_VMB_resistance_analysis.Rmd` reads only from
`data/processed/AJEV_VMB_AllData.xlsx`, which consolidates these files into one
workbook with a sheet per assay. Nothing in the notebook depends on this folder.
