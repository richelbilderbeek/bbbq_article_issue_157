output_filename <- "iedb_mhc_ligand_and_allele.csv"
message("output_filename: ", output_filename)

t <- iedbr::get_all_mhc_ligand_epitopes_and_mhc_alleles(
  max_n_queries = Inf,
  verbose = TRUE
)
readr::write_csv(t, output_filename)
testthat::expect_true(file.exists(output_filename))
