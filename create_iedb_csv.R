args <- commandArgs(trailingOnly = TRUE)

if (1 == 2) {
  setwd("~/GitHubs/bbbq_article_issue_157")
  list.files()
  args <- c("iedb_t_cell", "per_allele", 1)
  args <- c("iedb_t_cell", "per_allele", 1)
  args <- c("iedb_b_cell", "per_allele", 2)
  
  args <- c("iedb_t_cell", "all_alleles", 1)
  
  args <- c("iedb_b_cell", "all_alleles", 1)
  args <- c("iedb_mhc_ligand", "all_alleles", 1)
  args <- c("iedb_mhc_ligand", "all_alleles", 2)
  args <- c("iedb_mhc_ligand", "per_allele", 2)
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

if (allele_set == "all_alleles") {
  stop("No need for 'all_alleles'")
}

mhc_class <- as.numeric(args[3])
message("mhc_class: ", mhc_class)
testthat::expect_true(mhc_class %in% c(1, 2))

# Input files that are needed
b_cell_filename <- "iedb_b_cell_epitopes_and_mhc_alleles.csv"
mhc_ligand_filename <- "iedb_mhc_ligand_epitopes_and_mhc_alleles.csv"
t_cell_filename <- "iedb_t_cell_epitopes_and_mhc_alleles.csv"
testthat::expect_true(file.exists(b_cell_filename))
testthat::expect_true(file.exists(mhc_ligand_filename))
testthat::expect_true(file.exists(t_cell_filename))

input_filename <- character(0)
if (dataset == "iedb_b_cell") input_filename <- b_cell_filename
if (dataset == "iedb_mhc_ligand") input_filename <- mhc_ligand_filename
if (dataset == "iedb_t_cell") input_filename <- t_cell_filename
testthat::expect_equal(length(input_filename), 1)
message("input_filename: ", input_filename)

which_cells <- character(0)
if (dataset == "iedb_b_cell") which_cells <- "b_cell"
if (dataset == "iedb_mhc_ligand") which_cells <- "mhc_ligand"
if (dataset == "iedb_t_cell") which_cells <- "t_cell"
testthat::expect_equal(length(which_cells), 1)
message("which_cells: ", which_cells)

output_filename <- paste0(dataset, "_", allele_set, "_", mhc_class, ".csv")
message("output_filename: ", output_filename)


tibbles <- list()
i <- 1
allele_names <- character(0)
if (mhc_class == 1) allele_names <- bbbq::get_mhc1_allele_names()
if (mhc_class == 2) allele_names <- bbbq::get_mhc2_allele_names()
# if (allele_set == "all_alleles") allele_names <- "all"
testthat::expect_true(length(allele_names) > 0)

n_allele_names <- length(allele_names)

for (allele_name in allele_names) {
  message(
    i, "/", n_allele_names, ": ",
    "allele_name: ", allele_name, ", ",
    "input_filename: ", input_filename, ", ",
    "mhc_class: ", mhc_class
  )
  t <- readr::read_csv(
    file = input_filename,
    show_col_types = FALSE
  )
  has_valid_mhc_allele_name <- stringr::str_detect(
    string = t$mhc_allele_name,
    pattern = iedbr::mhc_allele_name_to_regex(allele_name)
  )
  sum(has_valid_mhc_allele_name)
  t <- t[has_valid_mhc_allele_name, ]
  t <- dplyr::distinct(t)
  t <- dplyr::rename(t, allele_name = mhc_allele_name)
  t$cell_type <- which_cells
  message("Got ", nrow(t), " new epitopes")
  tibbles[[i]] <- t
  i <- i + 1
}
t <- dplyr::bind_rows(tibbles)

testthat::expect_equal(names(t), c("linear_sequence", "allele_name", "cell_type"))
readr::write_csv(t, output_filename)
testthat::expect_true(file.exists(output_filename))
