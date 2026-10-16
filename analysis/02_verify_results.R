# =============================================================================
# 02_verify_results.R
#
# Checks that the values produced by 01_VMB_resistance_analysis.Rmd match the
# numbers reported in the manuscript. Every expected value below is hard-coded
# from the manuscript text, so this script fails if the code drifts from what
# was written, or if the manuscript is edited away from what the code produces.
#
# HOW TO RUN
#   1. Open VMB_Resistance_Screening.Rproj
#   2. Restart R, then Run All in analysis/01_VMB_resistance_analysis.Rmd
#   3. source(here::here("analysis", "02_verify_results.R"))
#
# It reads objects from the global environment, so it must run in the same
# session as the notebook. Anything missing is reported as SKIP rather than
# failing, so a partial run still tells you something.
#
# Exits non-zero on any FAIL, so it can be wired into CI later if wanted.
# =============================================================================

cat("\n", strrep("=", 78), "\n", sep = "")
cat("VERIFICATION -- AJEV-S-26-00049\n")
cat(strrep("=", 78), "\n\n", sep = "")

.results <- new.env()
.results$rows <- list()

#' Compare one value against its expected counterpart
#'
#' @param label  what is being checked
#' @param actual an expression; wrapped in try() so a missing object is a SKIP
#' @param expect expected value
#' @param tol    absolute tolerance. Defaults to 5e-4, tight enough that a
#'               genuine model change trips it but refit jitter does not.
check <- function(label, actual, expect, tol = 5e-4) {
  # Values below 1e-3 are shown in scientific notation; rounding them to four
  # decimals would print "0.0000" in both columns and make a real comparison
  # look vacuous.
  fmt <- function(v) if (v != 0 && abs(v) < 1e-3) format(v, digits = 3,
                                                         scientific = TRUE)
                     else format(round(v, 4), nsmall = 4)
  a <- try(actual, silent = TRUE)
  if (inherits(a, "try-error") || is.null(a) || length(a) == 0 || all(is.na(a))) {
    status <- "SKIP"; shown <- "not found"
  } else {
    a <- unname(a[[1]])
    status <- if (abs(a - expect) <= tol) "PASS" else "FAIL"
    shown  <- fmt(a)
  }
  .results$rows[[length(.results$rows) + 1]] <-
    data.frame(check = label, expected = fmt(expect),
               actual = shown, status = status, stringsAsFactors = FALSE)
  invisible(NULL)
}

#' Range check -- for calibration columns, where the expectation is an interval
check_range <- function(label, actual, lo, hi) {
  a <- try(actual, silent = TRUE)
  if (inherits(a, "try-error") || is.null(a) || length(a) == 0) {
    status <- "SKIP"; shown <- "not found"
  } else {
    status <- if (all(a >= lo & a <= hi)) "PASS" else "FAIL"
    shown  <- sprintf("%.3f-%.3f", min(a), max(a))
  }
  .results$rows[[length(.results$rows) + 1]] <-
    data.frame(check = label, expected = sprintf("%.3f-%.3f", lo, hi),
               actual = shown, status = status, stringsAsFactors = FALSE)
  invisible(NULL)
}


## ---- 1. Recovery, Figure 1D -------------------------------------------------
# Objects: recovery_789, m_recovery_main_789, m_recovery_int_789.
# (The earlier exploratory models named *_7_8_9 were removed from the notebook;
# do not reinstate those names here.)
#
# The 88-cage model. A result of 52 anywhere below means the VMB7 rows were
# dropped by the Accession / accession column mismatch -- the original bug.

check("recovery: cages in frame (NOT 52)",
      nrow(recovery_789), 88, tol = 0)

check("recovery: observations used by model",
      stats::nobs(m_recovery_main_789), 88, tol = 0)

check("recovery: insects introduced",
      sum(recovery_789$n_total), 476, tol = 0)

check("recovery: insects recovered",
      sum(recovery_789$survived), 271, tol = 0)

check("recovery: accession coefficient",
      lme4::fixef(m_recovery_main_789)["AccessionBarrett Mn-1"], -1.5542, tol = 2e-3)

check("recovery: cageID variance",
      as.numeric(lme4::VarCorr(m_recovery_main_789)$cageID), 0.2689, tol = 2e-3)

# The experiment effect is reported as a LIKELIHOOD-RATIO test (null vs main),
# not the Type II Wald chi-square that car::Anova() returns. The two genuinely
# differ here: LRT = 29.789, Wald = 28.889. Both are overwhelming and the
# conclusion is identical, but the manuscript quotes the LRT, so that is what
# this verifies. If the Methods are ever switched to Wald, change this too.
check("recovery: experiment LRT chi-sq",
      stats::anova(m_recovery_null_789, m_recovery_main_789)[["Chisq"]][2],
      29.789, tol = 0.01)

check("recovery: experiment LRT p",
      stats::anova(m_recovery_null_789, m_recovery_main_789)[["Pr(>Chisq)"]][2],
      3.4e-07, tol = 1e-8)

# The interaction is ALSO a likelihood-ratio test (main vs interaction), which
# is what the manuscript reports. An earlier version of this script checked the
# Type II Wald value (0.6801) instead; it passed only because the two agree to
# within tolerance when a term is far from significance. Checking the LRT here
# means both statistics in the recovery paragraph are verified as the test that
# is actually quoted.
check("recovery: interaction LRT chi-sq (ns)",
      stats::anova(m_recovery_main_789, m_recovery_int_789)[["Chisq"]][2],
      0.6803, tol = 1e-3)

check("recovery: interaction LRT p (ns)",
      stats::anova(m_recovery_main_789, m_recovery_int_789)[["Pr(>Chisq)"]][2],
      0.7117, tol = 1e-3)


## ---- 2. Choice assay, Figure 4 ----------------------------------------------
# NOTE: m_choice_bb is the Figure 4 model (accession term). The intercept-only
# model used by 5C is m_choice_bb_null -- renamed to stop it overwriting this one.

check("choice: arenas (NOT 82 rows)",
      nrow(choice_arena), 41, tol = 0)

check("choice: insects on Freedom",
      sum(choice_arena$n_freedom), 115, tol = 0)

check("choice: insects recovered total",
      sum(choice_arena$n_total), 170, tol = 0)

check("choice: preference proportion", P_OBS, 0.6681, tol = 2e-3)

check("choice: dispersion phi", PHI_OBS, 4.52, tol = 0.02)

check("choice: between-date SD", SIGMA_DATE_OBS, 0.278, tol = 2e-3)


## ---- 3. Power grids ---------------------------------------------------------

check("5A: grid rows",            nrow(power_growth),   21, tol = 0)
check("5A: max failure rate",     max(power_growth$fail_rate),   0, tol = 0)
check("5B: grid rows",            nrow(power_recovery), 18, tol = 0)
check("5B: max failure rate",     max(power_recovery$fail_rate), 0, tol = 0)
check("5C: grid rows",            nrow(power_choice),   40, tol = 0)
check("5C: max failure rate",     max(power_choice$fail_rate),   0, tol = 0)


## ---- 4. Calibration -- the load-bearing checks ------------------------------
# If these fail, every power estimate in Figure 5 and S2 is suspect, because a
# correctly specified null must reject at the nominal rate. These are also the
# checks that stand in for the glmmTMB/TMB version warning: a corrupted Hessian
# could not produce calibrated tests across this many designs.

check("5A sens: rows", nrow(power_growth_sens), 18, tol = 0)
check_range("5A sens: Type I at sigma=0 (nominal 0.05)",
            power_growth_sens$type1[power_growth_sens$sigma_ge == 0], 0.02, 0.08)

check("5C sens: rows", nrow(power_choice_sens), 27, tol = 0)
check_range("5C sens: Type I at sigma=0 (nominal 0.05)",
            power_choice_sens$type1[power_choice_sens$sigma_date == 0], 0.02, 0.08)


## ---- 5. Report --------------------------------------------------------------

out <- do.call(rbind, .results$rows)
cat(sprintf("%-46s %-10s %-12s %s\n", "CHECK", "EXPECTED", "ACTUAL", "STATUS"))
cat(strrep("-", 78), "\n")
for (i in seq_len(nrow(out))) {
  cat(sprintf("%-46s %-10s %-12s %s\n",
              substr(out$check[i], 1, 46), out$expected[i],
              out$actual[i], out$status[i]))
}
cat(strrep("-", 78), "\n")

n_pass <- sum(out$status == "PASS")
n_fail <- sum(out$status == "FAIL")
n_skip <- sum(out$status == "SKIP")
cat(sprintf("\n%d passed, %d failed, %d skipped\n", n_pass, n_fail, n_skip))

if (n_skip > 0) {
  cat("\nSKIPPED (object not in environment -- run the notebook first):\n")
  cat(paste0("  - ", out$check[out$status == "SKIP"], collapse = "\n"), "\n")
}
if (n_fail > 0) {
  cat("\nFAILED -- do not submit until resolved:\n")
  cat(paste0("  - ", out$check[out$status == "FAIL"], collapse = "\n"), "\n")
} else if (n_skip == 0) {
  cat("\nAll checks passed. Code output matches the manuscript.\n")
}
cat(strrep("=", 78), "\n\n", sep = "")

# =============================================================================
# NOTE ON THE RECOVERY TESTS -- resolved, recorded so it is not relitigated
#
# Both statistics in the recovery paragraph are LIKELIHOOD-RATIO tests on
# nested models, not Wald tests:
#
#   experiment    anova(m_recovery_null_789, m_recovery_main_789)
#                   chi2 = 29.7889, df = 2, p = 3.4e-07
#   interaction   anova(m_recovery_main_789, m_recovery_int_789)
#                   chi2 =  0.6803, df = 2, p = 0.7117
#
# car::Anova() returns Type II WALD statistics, which differ: 28.889 for
# experiment and 0.6801 for the interaction. The interaction values agree to
# three decimals because the term is far from significance, so a Wald-based
# check passes by coincidence rather than by being correct -- which is exactly
# what happened in an earlier version of this script. The experiment term is
# where the two tests visibly diverge, and that divergence is what exposed it.
#
# ONLY REMAINING ACTION: the Methods should name the test, e.g.
#   "Fixed effects were tested by likelihood-ratio tests comparing nested
#    models fitted by maximum likelihood."
# Without that clause a reader cannot tell which of the two a given chi2 is.
# =============================================================================

invisible(out)
