require(httr)

args <- commandArgs(trailingOnly = TRUE)

if (1 == 2) {
  setwd("~/GitHubs/bbbq_article_issue_157")
  list.files()
  args <- c("iedb_b_cell", "per_allele", 2)
  args <- c("iedb_t_cell", "per_allele", 1)
  args <- c("iedb_mhc_ligand", "all_alleles", 1)
  args <- c("iedb_mhc_ligand", "all_alleles", 2)
  args <- c("iedb_b_cell", "all_alleles", 1)
  args <- c("iedb_mhc_ligand", "per_allele", 2)
}
message("args: {", paste0(args, collapse = ", "), "}")
testthat::expect_equal(length(args), 3)
dataset <- as.character(args[1])
message("dataset: ", dataset)
testthat::expect_true(
  dataset %in% c(
    "schellens", "bergseng", "iedb_b_cell", "iedb_t_cell","iedb_mhc_ligand"
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
  # Use the IEDB names
  # Don't need in new BBBQ version
  haplotype <- stringr::str_replace_all(
    haplotype, "\\*([[:digit:]]{2})([[:digit:]]{2})", 
    "*\\1:\\2"
  )
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
  if (1 == 2) {
    if (which_cells == "b_cells") {
      params <- list(
        `structure_type` = 'eq.Linear peptide',
        `host_organism_iris` = 'cs.{NCBITaxon:9606}',
        `source_organism_iris` = 'cs.{NCBITaxon:9606}',
        `disease_names` = 'cs.{healthy}',
        `order` = 'structure_iri'
      )
      if (allele_set == "per_allele") {
        params$mhc_allele_names <- paste0("cs.{", haplotype, "}")
      } else {
        # Will filter out the correct MHC class later
      }
      params$bcell_ids <- 'not.is.null'
      res <- httr::GET(url = 'https://query-api.iedb.org/epitope_search', query = params)
    } else if (which_cells == "t_cells") {
      params <- list(
        `structure_type` = 'eq.Linear peptide',
        `host_organism_iris` = 'cs.{NCBITaxon:9606}',
        `source_organism_iris` = 'cs.{NCBITaxon:9606}',
        `disease_names` = 'cs.{healthy}',
        `order` = 'structure_iri'
      )
      if (allele_set == "per_allele") {
        params$mhc_allele_names <- paste0("cs.{", haplotype, "}")
      } else {
        # Will filter out the correct MHC class later
      }
      params$tcell_ids <- 'not.is.null'
      res <- httr::GET(url = 'https://query-api.iedb.org/epitope_search', query = params)
    } else {
      testthat::expect_equal(which_cells, "mhc_ligands")
      params <- list(
        `structure_type` = 'eq.Linear peptide',
        `disease_names` = 'cs.{healthy}',
        `order` = 'structure_iri'
      )
      res <- httr::GET(url = 'https://query-api.iedb.org/mhc_search', query = params)
    }
    content <- httr::content(res)
    message("Found ", length(content), " candidates")
    if ("message" %in% names(content)) {
      if (
          stringr::str_detect(
          string = content$message,
          pattern = "column .* does not exist"
        )
      ) {
        stop("Does not exist")
      }
    }
    if (!is.list(content)) stop("'content' must be a list")
    if (length(content) == 0) {
      message("No results for haplotype ", haplotype)
      next
    }
    testthat::expect_true("linear_sequence" %in% names(content[[1]]))
    linear_sequences <- purrr::map_chr(content, function(x) { x$linear_sequence } )
    t <- tibble::tibble(linear_sequence = linear_sequences)
    if (which_cells == "b_cells" || which_cells == "t_cells")  {
      # Do not check for MHC binding assays
      # content[[1]]
      # are_mhc_binding_essays <- purrr::map_lgl(content, function(x) { "MHC binding assay" %in% x$mhc_allele_evidences } ) 
      # head(are_mhc_binding_essays)
      # testthat::expect_equal(length(linear_sequences), length(are_mhc_binding_essays))
      # t <- t[are_mhc_binding_essays, ]
      # testthat::expect_equal(nrow(t), sum(are_mhc_binding_essays))
    } else {
      testthat::expect_equal(which_cells, "mhc_ligands")
      if (allele_set == "per_allele") {
        is_correct_haplotype <- purrr::map_lgl(content, function(x) {  haplotype == x$mhc_allele_name } ) 
        message("Candidates with correct haplotype: ", sum(is_correct_haplotype))
        t <- t[is_correct_haplotype, ]
        testthat::expect_equal(nrow(t), sum(is_correct_haplotype))
      } else {
        testthat::expect_equal(allele_set, "all_alleles")
        # content[[1]]$mhc_class
        # as.character(as.roman(mhc_class)) == content[[1]]$mhc_class
        is_correct_mhc_class <- purrr::map_lgl(content, function(x) {  as.character(as.roman(mhc_class)) == x$mhc_class } ) 
        t <- t[is_correct_mhc_class, ]
        testthat::expect_equal(nrow(t), sum(is_correct_mhc_class))
      }
    }
  }
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
