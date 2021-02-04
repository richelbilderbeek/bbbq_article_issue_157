args <- commandArgs(trailingOnly = TRUE)
message("args: {", paste0(args, collapse = ", "), "}")

if (1 == 2) {
  args <- c("1")
  args <- c("2")
}
testthat::expect_equal(length(args), 1)
mhc_class <- as.numeric(args[1])
message("mhc_class: ", mhc_class)
mhc_class <- as.numeric(args[1])
testthat::expect_true(mhc_class %in% c(1, 2))

matches_csv_filename <- paste0("matches_", mhc_class, ".csv")
message(
  "matches_csv_filename: ", matches_csv_filename,
  " (this is the source file)"
)
testthat::expect_true(file.exists(matches_csv_filename))

tmhs_pureseqtm_filename <- paste0("tmhs_pureseqtm_", mhc_class, ".csv")
message(
  "tmhs_pureseqtm_filename: ", tmhs_pureseqtm_filename,
  " (this is the output file)"
)

t_matches <- readr::read_csv(
  matches_csv_filename,
  col_type = readr::cols(
    epitope_sequence = readr::col_character(),
    n_matches = readr::col_double(),
    gene_name = readr::col_character(),
    sequence = readr::col_character()
  )
)

suppressPackageStartupMessages({
  library(bianchietal2017)
  library(dplyr, warn.conflicts = FALSE)
  library(ggplot2, quietly = TRUE)
})

#The question is, for unique mapping of an epitope onto the human reference proteome:
#are those epitopes indeed overlapping with a TMH?
t_unique_matches <- dplyr::filter(t_matches, n_matches == 1)
if (mhc_class == 1) testthat::expect_equal(nrow(t_unique_matches), 6994)
if (mhc_class == 2) testthat::expect_equal(nrow(t_unique_matches), 10450)

t_topology <- bbbq::get_topology(
  proteome_type = "representative",
  keep_selenoproteins = FALSE,
  topology_prediction_tool = "pureseqtmr"
)
testthat::expect_equal(nrow(t_topology), 20575)
names(t_topology)  <- c("gene_name", "pureseqtm_topology")

t_unique_matches <- dplyr::left_join(t_unique_matches, t_topology, by = "gene_name")
if (mhc_class == 1) testthat::expect_equal(nrow(t_unique_matches), 6994)
if (mhc_class == 2) testthat::expect_equal(nrow(t_unique_matches), 10450)

t_tmhs_pureseqtm <- t_unique_matches[
  stringr::str_which(
    t_unique_matches$pureseqtm_topology,
    "1"
  ),
]
if (mhc_class == 1) testthat::expect_equal(nrow(t_tmhs_pureseqtm), 974)
if (mhc_class == 2) testthat::expect_equal(nrow(t_tmhs_pureseqtm), 5793)

testthat::expect_equal(
  nchar(t_tmhs_pureseqtm$sequence),
  nchar(t_tmhs_pureseqtm$pureseqtm_topology)
)

epitope_locations <- stringr::str_locate(
  string = t_tmhs_pureseqtm$sequence,
  pattern = t_tmhs_pureseqtm$epitope_sequence
)
head(epitope_locations)
topology_overlap <- stringr::str_sub(
  t_tmhs_pureseqtm$pureseqtm_topology,
  start = epitope_locations[, 1],
  end = epitope_locations[, 2]
)
head(topology_overlap)


t_tmhs_pureseqtm$topology_overlap <- topology_overlap
t_tmhs_pureseqtm$from <- epitope_locations[, 1]
t_tmhs_pureseqtm$to <- epitope_locations[, 2]

n <- length(t_tmhs_pureseqtm$topology_overlap)
n_tmh <- length(stringr::str_which(t_tmhs_pureseqtm$topology_overlap, pattern = "1"))
n_tmh / n
# 0.1119097 = 11.19097%
print(n_tmh / n)
readr::write_csv(x = t_tmhs_pureseqtm, tmhs_pureseqtm_filename)
