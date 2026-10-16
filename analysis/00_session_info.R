# ---------------------------------------------------------------------------
# Regenerate the software versions and citations reported in the manuscript.
#
# Run this AFTER running 01_VMB_resistance_analysis.Rmd in the same session, so
# that every package the analysis actually loaded is captured.
#
# Output: results/session_info.txt  and  results/package_citations.txt
#
# Use these files to populate the Statistical Analyses section and the
# Literature Cited entries. Do not transcribe version numbers by hand.
# ---------------------------------------------------------------------------

here::i_am("analysis/00_session_info.R")
dir.create(here::here("results"), showWarnings = FALSE, recursive = TRUE)

# --- Full session record ---------------------------------------------------
si_path <- here::here("results", "session_info.txt")
sink(si_path)
cat("Generated:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), "\n\n")
print(R.version.string)
cat("\n--- sessionInfo() ---\n\n")
print(sessionInfo())
if (requireNamespace("devtools", quietly = TRUE)) {
  cat("\n--- devtools::session_info() ---\n\n")
  print(devtools::session_info())
}
sink()
message("Wrote ", si_path)

# --- Version table for the Statistical Analyses section --------------------
pkgs <- c(
  "lme4", "lmerTest", "glmmTMB", "mgcv", "simr",
  "emmeans", "multcomp", "multcompView", "car", "DHARMa", "binom",
  "dplyr", "tidyr", "tibble", "ggplot2", "forcats", "purrr",
  "readxl", "writexl", "patchwork", "cowplot", "ggpubr", "ggsignif",
  "here", "renv"
)
installed <- pkgs[vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
versions <- data.frame(
  package = installed,
  version = vapply(installed, function(p) as.character(utils::packageVersion(p)), character(1)),
  row.names = NULL
)
print(versions)

# --- Formal citations ------------------------------------------------------
cit_path <- here::here("results", "package_citations.txt")
sink(cit_path)
cat("Generated:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), "\n")
cat("Paste these into Literature Cited, reformatted to AJEV style\n")
cat("(DOI where available; 'and' before the final author).\n\n")
cat("R itself:\n"); print(citation())
for (p in installed) {
  cat("\n\n==================== ", p, " (v",
      as.character(utils::packageVersion(p)), ") ====================\n\n", sep = "")
  print(citation(p))
}
sink()
message("Wrote ", cit_path)

# --- Reminders -------------------------------------------------------------
message("\nCheck against the manuscript Statistical Analyses section:")
message("  * car::Anova() produces the LRT/Wald chi-square tests reported in")
message("    Results, but car is NOT cited. Add it.")
message("  * The R citation reads 'R Core Team 2021' while the version used is")
message("    4.6.0. Take the correct year from citation() in package_citations.txt.")
message("  * Verify every version number against the table printed above.")
message("  * Optional: multcompView, patchwork and cowplot are used for compact")
message("    letter displays and figure assembly but are not cited; AJEV does not")
message("    require citing plotting utilities, so this is a judgment call.")
message("  * glmmTMB IS now cited (beta-binomial models) -- previously flagged as")
message("    missing; that reminder is resolved.")
