matches_csv_filename <- "matches.csv"
testthat::expect_true(file.exists(matches_csv_filename))

t_matches <- readr::read_csv(matches_csv_filename)

library(bianchietal2017)
library(dplyr, warn.conflicts = FALSE)
library(ggplot2, quietly = TRUE)

#The question is, for unique mapping of an epitope onto the human reference proteome:
#are those epitopes indeed overlapping with a TMH?
t_unique_matches <- dplyr::filter(t_matches, n_matches == 1)
testthat::expect_equal(nrow(t_unique_matches), 6994)

t_topology <- bbbq::get_topology(
  proteome_type = "representative",
  keep_selenoproteins = FALSE,
  topology_prediction_tool = "tmhmm"
)
testthat::expect_equal(nrow(t_topology), 20575)
names(t_topology)  <- c("gene_name", "tmhmm_topology")

t_unique_matches <- dplyr::left_join(t_unique_matches, t_topology, by = "gene_name")
testthat::expect_equal(nrow(t_unique_matches), 6994)

t_tmhs_tmhmm <- t_unique_matches[
  stringr::str_which(
    t_unique_matches$tmhmm_topology,
    "(m|M)"
  ),
]
testthat::expect_equal(nrow(t_tmhs_tmhmm), 780)

testthat::expect_equal(
  nchar(t_tmhs_tmhmm$sequence),
  nchar(t_tmhs_tmhmm$tmhmm_topology)
)

epitope_locations <- stringr::str_locate(
  string = t_tmhs_tmhmm$sequence,
  pattern = t_tmhs_tmhmm$epitope_sequence
)
epitope_locations
topology_overlap <- stringr::str_sub(
  t_tmhs_tmhmm$tmhmm_topology,
  start = epitope_locations[, 1],
  end = epitope_locations[, 2]
)
topology_overlap

t_tmhs_tmhmm$topology_overlap <- topology_overlap
t_tmhs_tmhmm$from <- epitope_locations[, 1]
t_tmhs_tmhmm$to <- epitope_locations[, 2]

n <- length(t_tmhs_tmhmm$topology_overlap)
n_tmh <- length(stringr::str_which(t_tmhs_tmhmm$topology_overlap, pattern = "(M|m)"))
print(n_tmh / n)
# 0.1448718 = 14.48718 %

readr::write_csv(x = t_tmhs_tmhmm, "tmhs_tmhmm.csv")
