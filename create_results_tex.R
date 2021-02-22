t <- readr::read_csv("results.csv")

# Pretty print
t$mhc_class <- as.character(as.roman(t$mhc_class))



t$n_tmh <- paste0(format(round(t$f_tmh * 100, digits = 2), nsmall = 2), "% (", t$n_tmh, "/", t$n, ")")
t$n <- NULL
t$n_tmp <- NULL
t$f_tmh <- NULL
testthat::expect_equal(names(t)[1], "mhc_class")
testthat::expect_equal(names(t)[2], "tool")
testthat::expect_equal(names(t)[3], "n_tmh")
names(t) <- c("MHC class", "Tool", "n")
testthat::expect_equal(names(t)[1], "MHC class")
testthat::expect_equal(names(t)[2], "Tool")
testthat::expect_equal(names(t)[3], "n")
t
print(
  xtable::xtable(
    t,
    caption = paste(
      "Percentage of epitopes derived from a TMH",
      "found in the two elution studies,",
      "for the two different kind of topology",
      "prediction tools. The values between braces show the the number of",
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
