matches_csv_filename <- "matches.csv"
testthat::expect_true(file.exists(matches_csv_filename))

t_matches <- readr::read_csv(matches_csv_filename)

library(bianchietal2017)
library(dplyr, warn.conflicts = FALSE)
library(ggplot2, quietly = TRUE)

#The question is, for unique mapping of an epitope onto the human reference proteome:
#are those epitopes indeed overlapping with a TMH?
if (!file.exists("unique_matches_tmhmm.csv")) {
  t_unique_matches <- dplyr::filter(t_matches, n_matches == 1)
  t_unique_matches$tmhmm_topology <- NA
  readr::write_csv(t_unique_matches, "unique_matches_tmhmm.csv")
}
t_unique_matches <- readr::read_csv("unique_matches_tmhmm.csv")

for (i in seq_len(nrow(t_unique_matches))) {
  print(paste0(i, "/", nrow(t_unique_matches)))
  if (!is.na(t_unique_matches$tmhmm_topology[i])) next
  if (stringr::str_count(t_unique_matches$sequence[i], "U") != 0) next
  t_unique_matches$tmhmm_topology[i] <- tmhmm::predict_topology_from_sequence(
    protein_sequence = t_unique_matches$sequence[i]
  )
  readr::write_csv(t_unique_matches, "unique_matches_tmhmm.csv")
}

t_tmhs_tmhmm <- t_unique_matches[
  stringr::str_which(
    t_unique_matches$tmhmm_topology,
    "(m|M)"
  ),
]

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
