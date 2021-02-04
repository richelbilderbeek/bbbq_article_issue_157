t <- readr::read_csv("results.csv")

# Pretty print
t$mhc_class <- as.roman(t$mhc_class)
t$n_tmh <- paste0(round(t$f_tmh * 100), "% (", t$n_tmh, "/", t$n, ")")
t$n <- NULL
t$f_tmh <- NULL
t
print(
  xtable::xtable(t, type = "latex"),
  file = "results.tex"
)
