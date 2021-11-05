args <- commandArgs(trailingOnly = TRUE)
message("args: {", paste0(args, collapse = ", "), "}")

if (1 == 2) {
  args <- c("all_alleles")
  args <- c("per_allele")
}

testthat::expect_equal(length(args), 1)
allele_set <- as.character(args[1])
testthat::expect_true(allele_set %in% c("per_allele", "all_alleles"))
message("allele_set: ", allele_set)

results_filename <- paste0("results_", allele_set, ".csv")
message("results_filename: ", results_filename, " (this is the output file)")


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

if (allele_set == "per_allele") {
  # Schellens and Bergseng are all_alleles
  t <- t[!(t$dataset == "schellens"), ]
  t <- t[!(t$dataset == "bergseng"), ]
  
}

testthat::expect_identical(t, dplyr::distinct(t))

for (i in seq_len(nrow(t))) {
  tool <- t$tool[i]
  mhc_class <- t$mhc_class[i]
  dataset <- t$dataset[i]
  if (1 == 2) {
    dataset <- "iedb_mhc_ligand"
  }
  matches_filename <- paste0(
    "matches_", dataset, "_", allele_set, "_", mhc_class, ".csv"
  )
  message(i, "/", nrow(t), ": ", matches_filename)
  testthat::expect_true(file.exists(matches_filename))
  t$n[i] <- nrow(
    readr::read_csv(
      file = matches_filename,
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
  t$n_tmh[i] <- length(stringr::str_which(t_tmhs$topology_overlap, pattern = "[Mm]"))

}
t$f_tmh <- t$n_tmh / t$n
t
readr::write_csv(x = t, results_filename)
