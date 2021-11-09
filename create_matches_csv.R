# Here we look for the gene names and sequences for those epitopes that
# have exactly 1 match
args <- commandArgs(trailingOnly = TRUE)
message("args: {", paste0(args, collapse = ", "), "}")

if (1 == 2) {
  setwd("~/GitHubs/bbbq_article_issue_157"); list.files()
  # Schellens and Bergseng are all_alleles
  args <- c("1", "schellens", "all_alleles")
  args <- c("2", "bergseng", "all_alleles")

  # IEDB is per_allele
  args <- c("1", "iedb_b_cell", "per_allele")
  args <- c("1", "iedb_mhc_ligand", "per_allele")
  args <- c("2", "iedb_t_cell", "per_allele")
  args <- c("2", "iedb_t_cell", "per_allele")
}
testthat::expect_equal(length(args), 3)
mhc_class <- as.numeric(args[1])
message("mhc_class: ", mhc_class)
mhc_class <- as.numeric(args[1])
testthat::expect_true(mhc_class %in% c(1, 2))
dataset <- as.character(args[2])
message("dataset: ", dataset)
testthat::expect_true(
  dataset %in% c(
    "schellens",
    "bergseng",
    "iedb_b_cell",
    "iedb_mhc_ligand",
    "iedb_t_cell"
  )
)
testthat::expect_true(dataset != "schellens" || mhc_class == 1) # Schellens is MHC-I
testthat::expect_true(dataset != "bergseng" || mhc_class == 2) # Bergseng is MHC-II

allele_set <- as.character(args[3])
testthat::expect_true(allele_set %in% c("per_allele", "all_alleles"))
message("allele_set: ", allele_set)

matches_csv_filename <- paste0("matches_", dataset, "_", allele_set, "_", mhc_class, ".csv")
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

# Extract the epitope sequences from:
#   * Schellens et al., MHC-I
#   * Bergseng et al., MHC-II
#   * IEDB, MHC-I
#   * IEDB, MHC-II

#' @return a character vector of epitope sequences
get_epitope_sequences_schellens_1 <- function() {
  xlsx_filename <- "schellens_et_al_2015_sup_1.xlsl"
  # Here we obtain the (unique) epitope sequences from Schellens et al., 2015:
  bianchietal2017::download_schellens_et_al_2015_sup_1(
    xlsx_filename = xlsx_filename
  )
  t_schellens <- bianchietal2017::get_schellens_et_al_2015_sup_1(
    xlsx_filename = xlsx_filename
  )
  epitope_sequences <- unique(t_schellens$epitope_sequence)
  # There are 7897 unique epitope sequences.
  testthat::expect_equal(7897, length(epitope_sequences))
  epitope_sequences
}

#' @return a character vector of epitope sequences
get_epitope_sequences_bergseng_2 <- function() {
  t_berseng <- bbbq::get_bergseng_et_al_2015_sup_1()
  epitope_sequences <- unique(t_berseng$Sequence)
  testthat::expect_equal(12712, length(epitope_sequences))
  epitope_sequences
}

#' @return a character vector of epitope sequences
get_epitope_sequences_iedb <- function(dataset, mhc_class, allele_set) {
  filename <- paste0(dataset, "_", allele_set, "_", mhc_class, ".csv")
  message("Reading file: ", filename)
  testthat::expect_true(file.exists(filename))
  t <- readr::read_csv(
    filename,
    col_types = readr::cols(
      linear_sequence = readr::col_character(),
      allele_name = readr::col_character(),
      cell_type = readr::col_character()
    )
  )
  message("Number of sequences in file ", filename, ": ", nrow(t))
  allele_names <- character(0)
  if (mhc_class == 1) allele_names <- bbbq::get_mhc1_allele_names()
  if (mhc_class == 2) allele_names <- bbbq::get_mhc2_allele_names()
  testthat::expect_true(length(allele_names) > 0)
  t <- t[t$allele_name %in% allele_names, ]
  t <- na.omit(t)
  message("Number of sequences in file with MHC class ", mhc_class, ": ", nrow(t))
  epitope_sequences <- t$linear_sequence
  testthat::expect_equal(sum(is.na(epitope_sequences)), 0)
  epitope_sequences
}

epitope_sequences <- NA
if (mhc_class == 1 && dataset == "schellens") {
  epitope_sequences <- get_epitope_sequences_schellens_1()
} else if (mhc_class == 2 && dataset == "bergseng") {
  epitope_sequences <- get_epitope_sequences_bergseng_2()
} else {
  epitope_sequences <- get_epitope_sequences_iedb(
    dataset = dataset,
    mhc_class = mhc_class,
    allele_set = allele_set
  )
}

if (mhc_class == 2 && dataset == "iedb_t_cell" && allele_set == "all_alleles") {
  testthat::expect_equal(length(epitope_sequences), 921)
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
