#!/usr/bin/env Rscript
# Verify the workshop setup and render the Typst sample to cache its fonts.

ok  <- function(x) cat(sprintf("  [ok]   %s\n", x))
bad <- function(x) cat(sprintf("  [FAIL] %s\n", x))
fails <- 0L
fail <- function(x) { bad(x); fails <<- fails + 1L }

cat("== RaukR 2026 Quarto setup check ==\n\n")

# 1. R version
cat("R\n")
if (getRversion() >= "4.5.0") ok(sprintf("R %s (>= 4.5)", getRversion())) else
  fail(sprintf("R %s. Install R 4.5 or later to use datasets::penguins.", getRversion()))

# 2. Quarto CLI
cat("Quarto\n")
if (nzchar(Sys.which("quarto"))) {
  qv <- tryCatch(system2("quarto", "--version", stdout = TRUE), error = function(e) NA_character_)
  if (!is.na(qv) && numeric_version(qv) >= "1.9.0") ok(sprintf("Quarto %s (>= 1.9)", qv)) else
    fail(sprintf("Quarto %s. Install Quarto 1.9 or later.", qv))
} else fail("quarto was not found on PATH. Install Quarto 1.9 or later.")

# 3. Packages (the content packages)
cat("R packages\n")
pkgs <- c("dplyr", "ggplot2", "ggrepel", "gt", "ggokabeito", "brand.yml",
          "prismatic", "knitr", "rmarkdown")
have <- pkgs %in% rownames(installed.packages())
for (i in seq_along(pkgs)) if (have[i]) ok(pkgs[i]) else fail(paste0(pkgs[i], " is not installed."))

# 4. Data (base-R penguins, R >= 4.5)
cat("Data\n")
if (exists("penguins", where = asNamespace("datasets")))
  ok("datasets::penguins available") else
  fail("datasets::penguins was not found. Install R 4.5 or later.")

# 5. Typst render and font cache
cat("Typst PDF and font check\n")
sample <- file.path("day1-intro", "sample-typst.qmd")
if (!file.exists(sample)) {
  fail(sprintf("%s was not found. Run this script from the top folder of the download.", sample))
} else if (fails > 0L) {
  cat("  [skip] Fix the failures above, then run the check again.\n")
} else {
  # Use the CLI directly; the quarto R package is not required.
  code <- tryCatch(system2("quarto", c("render", shQuote(sample)),
                           stdout = FALSE, stderr = FALSE),
                   error = function(e) 1L)
  pdf <- file.path("day1-intro", "sample-typst.pdf")
  if (identical(as.integer(code), 0L) && file.exists(pdf)) ok(paste("rendered", pdf)) else
    fail("Typst rendering failed. Run `quarto render day1-intro/sample-typst.qmd` to see the error.")
}

cat("\n")
if (fails == 0L) cat(">> All good. You are ready for Day 1.\n") else
  cat(sprintf(">> %d check(s) failed. Review the [FAIL] lines above.\n", fails))
# Do not terminate an interactive session when this file is sourced.
if (!interactive()) quit(status = if (fails == 0L) 0L else 1L)
invisible(fails)
