
tmhs_tmhmm_csv_filename <- "tmhs_tmhmm.csv"
tmhs_pureseqtm_csv_filename <- "tmhs_pureseqtm.csv"
testthat::expect_true(file.exists(tmhs_tmhmm_csv_filename))
testthat::expect_true(file.exists(tmhs_pureseqtm_csv_filename))

t <- tidyr::expand_grid(
  tool = c("PureseqTM", "TMHMM"),
  mhc_class = c(1, 2),
  n = NA,
  n_tmh = NA,
  f_tmh = NA,
)
for (i in seq_len(nrow(t))) {
  tool <- t$tool[i]
  mhc_class <- t$mhc_class[i]
  tmhs_csv_filename <- NA
  if (tool == "PureseqTM") {
    tmhs_csv_filename <- paste0("tmhs_pureseqtm_", mhc_class, ".csv")
  } else {
    testthat::expect_equal(tool, "TMHMM")
    tmhs_csv_filename <- paste0("tmhs_tmhmm_", mhc_class, ".csv")
  }
  testthat::expect_true(file.exists(tmhs_csv_filename))
  t_tmhs <- readr::read_csv(tmhs_csv_filename)
  t$n[i] <- length(t_tmhs$topology_overlap)
  t$n_tmh[i] <- length(stringr::str_which(t_tmhs$topology_overlap, pattern = "[1Mm]"))

}

t$f_tmh <- t$n_tmh / t$n
readr::write_csv(x = t, "results.csv")
