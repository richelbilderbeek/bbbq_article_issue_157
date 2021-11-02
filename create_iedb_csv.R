require(httr)

args <- commandArgs(trailingOnly = TRUE)

if (1 == 2) {
  setwd("~/GitHubs/bbbq_article_issue_157")
  list.files()
  args <- c("iedb_b_cell")
  args <- c("iedb_t_cell")
  args <- c("iedb_mhc_ligand")
}
message("args: {", paste0(args, collapse = ", "), "}")
testthat::expect_equal(length(args), 1)
dataset <- as.character(args[1])
message("dataset: ", dataset)
testthat::expect_true(
  dataset %in% c(
    "schellens", "bergseng", "iedb_b_cell", "iedb_t_cell","iedb_mhc_ligand"
  )
)

output_filename <- paste0(dataset, ".csv")
message("output_filename: ", output_filename)

which_cells <- NA
if (dataset == "iedb_t_cell") which_cells <- "t_cells"
if (dataset == "iedb_b_cell") which_cells <- "b_cells"
if (dataset == "iedb_mhc_ligand") which_cells <- "mhc_ligands"
testthat::expect_true(!is.na(which_cells))
message("which_cells: ", which_cells)


  
tibbles <- list()
i <- 1
haplotypes <- bbbq::get_mhc_haplotypes()
n_haplotypes <- length(haplotypes)

for (haplotype in haplotypes) {
  # Use the IEDB names
  haplotype <- stringr::str_replace_all(
    haplotype, "\\*([[:digit:]]{2})([[:digit:]]{2})", 
    "*\\1:\\2"
  )
  message(i, "/", n_haplotypes, ": ", haplotype, ", which_cells: ", which_cells)
  params <- list(
    `structure_type` = 'eq.Linear peptide',
    `mhc_allele_names` = paste0("cs.{", haplotype, "}"),
    `host_organism_iris` = 'cs.{NCBITaxon:9606}',
    `source_organism_iris` = 'cs.{NCBITaxon:9606}',
    `disease_names` = 'cs.{healthy}',
    `order` = 'structure_iri'
  )
  if (which_cells == "b_cells") {
    params$bcell_ids <- 'not.is.null'
  } else if (which_cells == "t_cells") {
    params$tcell_ids <- 'not.is.null'
  } else {
    testthat::expect_equal(which_cells, "mhc_ligands")
    params$mhcligand_ids <- 'not.is.null'
  }
  res <- httr::GET(url = 'https://query-api.iedb.org/epitope_search', query = params)
  content <- httr::content(res)
  if (!is.list(content)) stop("'content' must be a list")
  if (length(content) == 0) {
    message("No results for haplotype ", haplotype)
    next
  }
  testthat::expect_true("linear_sequence" %in% names(content[[1]]))
  content
  linear_sequences <- purrr::map_chr(content, function(x) { x$linear_sequence } )
  are_mhc_binding_essays <- purrr::map_lgl(content, function(x) { "MHC binding assay" %in% x$mhc_allele_evidences } ) 
  testthat::expect_equal(length(linear_sequences), length(are_mhc_binding_essays))
  t <- tibble::tibble(linear_sequence = linear_sequences)
  t <- t[are_mhc_binding_essays, ]
  testthat::expect_equal(nrow(t), sum(are_mhc_binding_essays))
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
