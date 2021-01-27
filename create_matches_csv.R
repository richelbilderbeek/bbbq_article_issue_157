# Here we look for the gene names and sequences for those epitopes that
# have exactly 1 match:

library(bianchietal2017)
library(dplyr, warn.conflicts = FALSE)
library(ggplot2, quietly = TRUE)

# Here we obtain the shorter/representative human reference proteome used:
t_proteome <- bbbq::get_proteome(
  keep_selenoproteins = FALSE,
  proteome_type = "representative"
)
# The human reference proteome contains 20600 sequences,
# removed the 25 selenoproteins.
testthat::expect_equal(nrow(t_proteome), 20575)

# Here we obtain the (unique) epitope sequences from Schellens et al., 2015:
t_schellens <- bianchietal2017::get_schellens_et_al_2015_sup_1()
epitope_sequences <- unique(t_schellens$epitope_sequence)
# There are 7897 unique epitope sequences.
testthat::expect_equal(7897, length(epitope_sequences))

t_matches <- tibble::tibble(
  epitope_sequence = epitope_sequences,
  n_matches = NA,
  gene_name = NA,
  sequence = NA
)
for (i in seq_len(nrow(t_matches))) {
  print(paste0(i, "/", nrow(t_matches)))
  matches <- stringr::str_which(
    string = t_proteome$sequence,
    pattern = t_matches$epitope_sequence[i]
  )
  t_matches$n_matches[i] <- length(matches)
  if (length(matches) == 1) {
    t_matches$sequence[i] <- t_proteome$sequence[matches]
    t_matches$gene_name[i] <- t_proteome$name[matches]
  }
}

matches_csv_filename <- "matches.csv"
readr::write_csv(t_matches, matches_csv_filename)
testthat::expect_true(file.exists(matches_csv_filename))
