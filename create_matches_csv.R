# Here we look for the gene names and sequences for those epitopes that
# have exactly 1 match
args <- commandArgs(trailingOnly = TRUE)
message("args: {", paste0(args, collapse = ", "), "}")

if (1 == 2) {
  args <- c("1")
}
testthat::expect_equal(length(args), 1)
mhc_class <- as.numeric(args[1])
message("mhc_class: ", mhc_class)
mhc_class <- as.numeric(args[1])
testthat::expect_true(mhc_class %in% c(1, 2))

matches_csv_filename <- paste0("matches_", mhc_class, ".csv")
message(
  "matches_csv_filename: ", matches_csv_filename,
  " (this is the file to be created)"
)

suppressPackageStartupMessages({
  library(bianchietal2017)
  library(dplyr, warn.conflicts = FALSE)
  library(ggplot2, quietly = TRUE)
})

# Here we obtain the shorter/representative human reference proteome used:
t_proteome <- bbbq::get_proteome(
  keep_selenoproteins = FALSE,
  proteome_type = "representative"
)
# The human reference proteome contains 20600 sequences,
# removed the 25 selenoproteins.
testthat::expect_equal(nrow(t_proteome), 20575)

epitope_sequences <- NA
if (mhc_class == 1) {
  # Here we obtain the (unique) epitope sequences from Schellens et al., 2015:
  t_schellens <- bianchietal2017::get_schellens_et_al_2015_sup_1()
  epitope_sequences <- unique(t_schellens$epitope_sequence)
  # There are 7897 unique epitope sequences.
  testthat::expect_equal(7897, length(epitope_sequences))
} else {
  # Here we obtain the (unique) epitope sequences from Bergseng et al., 2015:
  t_berseng <- bbbq::get_bergseng_et_al_2015_sup_1()
  epitope_sequences <- unique(t_berseng$Sequence)
  testthat::expect_equal(12712, length(epitope_sequences))
}

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

readr::write_csv(t_matches, matches_csv_filename)
testthat::expect_true(file.exists(matches_csv_filename))
