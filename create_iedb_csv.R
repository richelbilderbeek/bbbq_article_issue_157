require(httr)

args <- commandArgs(trailingOnly = TRUE)

if (1 == 2) {
  setwd("~/GitHubs/bbbq_article_issue_157")
  list.files()
  args <- c("iedb_t_cell", "per_allele", 1)
  args <- c("iedb_mhc_ligand", "per_allele", 2)


  args <- c("iedb_t_cell", "per_allele", 1)
  args <- c("iedb_b_cell", "per_allele", 2)
  args <- c("iedb_mhc_ligand", "all_alleles", 1)
  args <- c("iedb_mhc_ligand", "all_alleles", 2)
  args <- c("iedb_b_cell", "all_alleles", 1)
}
message("args: {", paste0(args, collapse = ", "), "}")
testthat::expect_equal(length(args), 3)
dataset <- as.character(args[1])
message("dataset: ", dataset)
# No Schellens or Bergseng here
testthat::expect_true(
  dataset %in% c(
    "iedb_b_cell", "iedb_t_cell","iedb_mhc_ligand"
  )
)

allele_set <- as.character(args[2])
testthat::expect_true(allele_set %in% c("per_allele", "all_alleles"))
message("allele_set: ", allele_set)

mhc_class <- as.numeric(args[3])
message("mhc_class: ", mhc_class)
testthat::expect_true(mhc_class %in% c(1, 2))

output_filename <- paste0(dataset, "_", allele_set, "_", mhc_class, ".csv")
message("output_filename: ", output_filename)

which_cells <- NA
if (dataset == "iedb_t_cell") which_cells <- "t_cells"
if (dataset == "iedb_b_cell") which_cells <- "b_cells"
if (dataset == "iedb_mhc_ligand") which_cells <- "mhc_ligands"
testthat::expect_true(!is.na(which_cells))
message("which_cells: ", which_cells)



tibbles <- list()
i <- 1
haplotypes <- NA
if (mhc_class == 1) haplotypes <- bbbq::get_mhc1_haplotypes()
if (mhc_class == 2) haplotypes <- bbbq::get_mhc2_haplotypes()
if (allele_set == "all_alleles") haplotypes <- "all"
n_haplotypes <- length(haplotypes)

for (haplotype in haplotypes) {
  message(
    i, "/", n_haplotypes, ": ",
    "haplotype: ", haplotype, ", ",
    "which_cells: ", which_cells, ", ",
    "mhc_class: ", mhc_class
  )
  epitopes <- c()
  if (which_cells == "b_cells") {
    if (haplotype == "all") {
      epitopes <- iedbr::get_all_b_cell_epitopes()
    } else {
      epitopes <- iedbr::get_all_b_cell_epitopes(
        mhc_allele_names = paste0("cs.{", haplotype,"}")
      )
    }
  }
  if (which_cells == "mhc_ligands") {
    if (haplotype == "all") {
      epitopes <- iedbr::get_all_mhc_ligand_epitopes()
    } else {
      epitopes <- iedbr::get_all_mhc_ligand_epitopes(
        mhc_allele_name = paste0("cs.{", haplotype,"}")
      )
    }
  }
  if (which_cells == "t_cells") {
    if (haplotype == "all") {
      epitopes <- iedbr::get_all_t_cell_epitopes()
    } else {
      epitopes <- iedbr::get_all_t_cell_epitopes(
        mhc_allele_names = paste0("cs.{", haplotype,"}")
      )
    }
  }
  testthat::expect_true(length(epitopes) != 0)

  epitopes <- unique(sort(epitopes))
  testthat::expect_equal(length(epitopes), length(unique(epitopes)))
  t <- tibble::tibble(linear_sequence = epitopes)
  t <- dplyr::distinct(t)
  t$haplotype <- haplotype
  t$cell_type <- which_cells
  message("Got ", nrow(t), " new epitopes")
  tibbles[[i]] <- t
  i <- i + 1
}
t <- dplyr::bind_rows(tibbles)
t
readr::write_csv(t, output_filename)
testthat::expect_true(file.exists(output_filename))
