library(dplyr)

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

dataset <- c()
if (allele_set == "all_alleles") dataset <- c("schellens", "bergseng")
# if (allele_set == "per_allele") dataset <- c("iedb_b_cell", "iedb_mhc_ligand", "iedb_t_cell")
if (allele_set == "per_allele") dataset <- c("iedb_mhc_ligand", "iedb_t_cell")
testthat::expect_true(length(dataset) > 0)
message("dataset: ", paste(dataset, collapse = ", "))

results_filename <- paste0("results_", allele_set, ".csv")
message("results_filename: ", results_filename, " (this is the output file)")


# tool <- c("PureseqTM", "TMHMM"),
tool <- "TMHMM"
message("tool: ", tool)


t <- tidyr::expand_grid(
  mhc_class = c(1, 2),
  tool = tool,
  dataset = dataset,
  n = NA,     # Number of epitopes in proteome
  n_tmh = NA, # Number of epitopes in transmembrane helix
  f_tmh = NA, # Fraction of epitopes in transmembrane helix
)
# Schellens is MHC-I only, remove MHC-II
t <- t[!(t$dataset == "schellens" & t$mhc_class == 2), ]
# Bergseng is MHC-II only, remove MHC-I
t <- t[!(t$dataset == "bergseng" & t$mhc_class == 1), ]

testthat::expect_identical(t, dplyr::distinct(t))

for (i in seq_len(nrow(t))) {
  tool <- t$tool[i]
  mhc_class <- t$mhc_class[i]
  dataset <- t$dataset[i]
  if (1 == 2) {
    dataset <- "iedb_mhc_ligand"
  }
  # message(i, "/", nrow(t), ": ", matches_filename)
  # matches_filename <- paste0(
  #   "matches_", dataset, "_", allele_set, "_", mhc_class, ".csv"
  # )
  # message(i, "/", nrow(t), ": ", matches_filename)
  # testthat::expect_true(file.exists(matches_filename))
  # t$n[i] <- nrow(
  #   readr::read_csv(
  #     file = matches_filename,
  #     show_col_types = FALSE
  #   )
  # )
  tmhs_csv_filename <- c()
  if (tool == "PureseqTM") {
    tmhs_csv_filename <- paste0("tmhs_pureseqtm_", dataset, "_", allele_set, "_", mhc_class, ".csv")
  } else {
    testthat::expect_equal(tool, "TMHMM")
    tmhs_csv_filename <- paste0("tmhs_tmhmm_", dataset, "_", allele_set, "_", mhc_class, ".csv")
  }
  message(i, "/", nrow(t), ": ", tmhs_csv_filename)
  testthat::expect_true(length(tmhs_csv_filename) > 0)
  if (!file.exists(tmhs_csv_filename)) {
    stop("Cannot find 'tmhs_csv_filename' with name ", tmhs_csv_filename)  
  }
  testthat::expect_true(file.exists(tmhs_csv_filename))
  t_tmhs <- readr::read_csv(tmhs_csv_filename, show_col_types = FALSE)
  t$n[i] <- nrow(t_tmhs)
  t$n_tmh[i] <- length(stringr::str_which(t_tmhs$topology_overlap, pattern = "[Mm]"))

}
t$f_tmh <- t$n_tmh / t$n
t
readr::write_csv(x = t, results_filename)

if (allele_set == "all_alleles") return()

#
#
# Do this again, but per allele name
#
#
# Second output file:
results_filename <- paste0("results_", allele_set, "_", allele_set, ".csv")
message("results_filename: ", results_filename, " (this is the output file)")

# Now do this per allele
tibbles <- list()
for (i in seq_len(nrow(t))) {
  tool <- t$tool[i]
  mhc_class <- t$mhc_class[i]
  dataset <- t$dataset[i]
  matches_filename <- paste0(
    "matches_", dataset, "_", allele_set, "_", mhc_class, ".csv"
  )
  message(i, "/", nrow(t), ": ", matches_filename)
  testthat::expect_true(file.exists(matches_filename))
  tmhs_csv_filename <- c()
  if (tool == "PureseqTM") {
    tmhs_csv_filename <- paste0("tmhs_pureseqtm_", dataset, "_", allele_set, "_", mhc_class, ".csv")
  } else {
    testthat::expect_equal(tool, "TMHMM")
    tmhs_csv_filename <- paste0("tmhs_tmhmm_", dataset, "_", allele_set, "_", mhc_class, ".csv")
  }
  testthat::expect_true(length(tmhs_csv_filename) > 0)
  if (!file.exists(tmhs_csv_filename)) {
    stop("Cannot find 'tmhs_csv_filename' with name ", tmhs_csv_filename)  
  }
  testthat::expect_true(file.exists(tmhs_csv_filename))
  t_tmhs <- readr::read_csv(tmhs_csv_filename, show_col_types = FALSE)
  testthat::expect_true(all(t_tmhs$n_matches == 1))
  t_per_allele <- t_tmhs %>% select(allele_name, cell_type, topology_overlap)
  t_per_allele$is_overlap <- stringr::str_detect(
    t_tmhs$topology_overlap, 
    pattern = "[Mm]"
  )
  t_per_allele <- t_per_allele %>% group_by(allele_name, cell_type) %>% 
    summarize(
      f_tmh = mean(is_overlap), 
      n = n(), 
      .groups = "drop"
    )
  tibbles[[i]] <- t_per_allele
}
t_summarized <- dplyr::bind_rows(tibbles)
t_summarized
readr::write_csv(x = t_summarized, results_filename)
