max_n_queries <- Inf

if (pureseqtmr::is_on_ci()) {
  max_n_queries <- 3
}

message("max_n_queries: ", max_n_queries)

output_filename <- "iedb_t_cell_epitopes_and_mhc_alleles.csv"
message("output_filename: ", output_filename)

t <- iedbr::get_all_t_cell_epitopes_and_mhc_alleles(
  max_n_queries = max_n_queries,
  verbose = TRUE
)
t
readr::write_csv(t, output_filename)
testthat::expect_true(file.exists(output_filename))
