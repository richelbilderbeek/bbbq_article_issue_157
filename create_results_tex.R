t <- readr::read_csv(
  "results_per_allele.csv",
  show_col_types = FALSE
)
t <- t[!is.na(t$f_tmh), ]

# Pretty print
t$mhc_class <- as.character(as.roman(t$mhc_class))



t$n_tmh <- paste0(format(round(t$f_tmh * 100, digits = 2), nsmall = 2), "% (", t$n_tmh, "/", t$n, ")")
t$n <- NULL
t$f_tmh <- NULL
testthat::expect_equal(names(t)[1], "mhc_class")
testthat::expect_equal(names(t)[2], "tool")
testthat::expect_equal(names(t)[3], "dataset")
testthat::expect_equal(names(t)[4], "n_tmh")
names(t) <- c("MHC class", "Tool", "Dataset", "n")
testthat::expect_equal(names(t)[1], "MHC class")
testthat::expect_equal(names(t)[2], "Tool")
testthat::expect_equal(names(t)[3], "Dataset")
testthat::expect_equal(names(t)[4], "n")

t$Tool <- NULL
t
print(
  xtable::xtable(
    t,
    caption = paste(
      "Percentage of epitopes derived from a TMH",
      "for epitopes taken from the IEDB,",
      "for two different types of assays: ",
      "an MHC ligand assay, as well as a T cell assay. ",
      "The values between braces show the the number of",
      "epitopes that were predicted to overlapping with a TMH per all",
      "epitopes that could be uniquely mapped to the",
      "representative human reference proteome."
    ),
    label = "tab:elution",
    type = "latex"
  ),
  include.rownames = FALSE,
  file = "results.tex"
)
t
readLines("results.tex")
