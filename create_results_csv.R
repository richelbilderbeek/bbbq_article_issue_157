t <- tidyr::expand_grid(
  mhc_class = c(1, 2),
  tool = c("PureseqTM", "TMHMM"),
  dataset = c(
    "schellens", 
    "bergseng", 
    "iedb_b_cell", 
    "iedb_mhc_ligand", 
    "iedb_t_cell"
  ),
  n = NA,     # Number of epitopes in proteome
  n_tmp = NA, # Number of epitopes in transmembrane protein
  n_tmh = NA, # Number of epitopes in transmembrane helix
  f_tmh = NA,
)
# Schellens is MHC-I only, remove MHC-II
t <- t[!(t$dataset == "schellens" & t$mhc_class == 2), ]
# Bergseng is MHC-II only, remove MHC-I
t <- t[!(t$dataset == "bergseng" & t$mhc_class == 1), ]

t
testthat::expect_identical(t, dplyr::distinct(t))
for (i in seq_len(nrow(t))) {
  tool <- t$tool[i]
  mhc_class <- t$mhc_class[i]
  dataset <- t$dataset[i]
  
  
  t$n[i] <- nrow(
    readr::read_csv(
      file = paste0("matches_", dataset, "_", mhc_class, ".csv"),
      show_col_types = FALSE
    )
  )
  tmhs_csv_filename <- NA
  if (tool == "PureseqTM") {
    tmhs_csv_filename <- paste0("tmhs_pureseqtm_", dataset, "_", mhc_class, ".csv")
  } else {
    testthat::expect_equal(tool, "TMHMM")
    tmhs_csv_filename <- paste0("tmhs_tmhmm_", dataset, "_", mhc_class, ".csv")
  }
  testthat::expect_true(file.exists(tmhs_csv_filename))
  t_tmhs <- readr::read_csv(tmhs_csv_filename, show_col_types = FALSE)
  t$n_tmp[i] <- length(t_tmhs$topology_overlap)
  t$n_tmh[i] <- length(stringr::str_which(t_tmhs$topology_overlap, pattern = "[1Mm]"))

}
t
t$f_tmh <- t$n_tmh / t$n
readr::write_csv(x = t, "results.csv")
