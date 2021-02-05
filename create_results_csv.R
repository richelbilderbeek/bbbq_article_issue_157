t <- tidyr::expand_grid(
  mhc_class = c(1, 2),
  tool = c("PureseqTM", "TMHMM"),
  n = NA,     # Number of epitopes in proteome
  n_tmp = NA, # Number of epitopes in transmembrane protein
  n_tmh = NA, # Number of epitopes in transmembrane helix
  f_tmh = NA,
)
for (i in seq_len(nrow(t))) {
  tool <- t$tool[i]
  mhc_class <- t$mhc_class[i]
  t$n[i] <- nrow(readr::read_csv(paste0("matches_", mhc_class, ".csv")))
  tmhs_csv_filename <- NA
  if (tool == "PureseqTM") {
    tmhs_csv_filename <- paste0("tmhs_pureseqtm_", mhc_class, ".csv")
  } else {
    testthat::expect_equal(tool, "TMHMM")
    tmhs_csv_filename <- paste0("tmhs_tmhmm_", mhc_class, ".csv")
  }
  testthat::expect_true(file.exists(tmhs_csv_filename))
  t_tmhs <- readr::read_csv(tmhs_csv_filename)
  t$n_tmp[i] <- length(t_tmhs$topology_overlap)
  t$n_tmh[i] <- length(stringr::str_which(t_tmhs$topology_overlap, pattern = "[1Mm]"))

}

t$f_tmh <- t$n_tmh / t$n
readr::write_csv(x = t, "results.csv")
