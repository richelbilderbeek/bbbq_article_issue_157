tmhs_tmhmm_csv_filename <- "tmhs_tmhmm.csv"
tmhs_pureseqtm_csv_filename <- "tmhs_pureseqtm.csv"
testthat::expect_true(file.exists(tmhs_tmhmm_csv_filename))
testthat::expect_true(file.exists(tmhs_pureseqtm_csv_filename))

t <- tibble::tibble(
  tool = c("PureseqTM", "TMHMM"),
  n = NA,
  n_tmh = NA,
  f_tmh = NA,
)

# PureseqTM
t_tmhs_pureseqtm <- readr::read_csv(tmhs_pureseqtm_csv_filename)
t$n[1] <- length(t_tmhs_pureseqtm$topology_overlap)
t$n_tmh[1] <- length(stringr::str_which(t_tmhs_pureseqtm$topology_overlap, pattern = "1"))

# TMHMM
t_tmhs_tmhmm <- readr::read_csv(tmhs_tmhmm_csv_filename)
t$n[2] <- length(t_tmhs_tmhmm$topology_overlap)
t$n_tmh[2] <- length(stringr::str_which(t_tmhs_tmhmm$topology_overlap, pattern = "(M|m)"))

t$f_tmh <- t$n_tmh / t$n
readr::write_csv(x = t, "results.csv")
