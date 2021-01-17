library(bianchietal2017)
library(dplyr, warn.conflicts = FALSE)
library(ggplot2, quietly = TRUE)

if (1 == 2) {
  setwd("~/GitHubs/bbbq_article/issue_157/")
}
#It is claimed that some eluates from Schellens et al., 2015,
#are derived from TMHs.

#Here we obtain the human reference proteome used:
t_proteome <- get_proteome(fasta_gz_filename = download_proteome())
names(t_proteome)

# The human reference proteome contains 20600 sequences.
testthat::expect_equal(nrow(t_proteome), 20600)


# Here we obtain the (unique) epitope sequences from Schellens et al., 2015:
t_schellens <- get_schellens_et_al_2015_sup_1(xlsx_filename = download_schellens_et_al_2015_sup_1())
epitope_sequences <- unique(t_schellens$epitope_sequence)

# There are 7897 unique epitope sequences.
testthat::expect_equal(7897, length(epitope_sequences))

# Here we look for the gene names and sequences for those epitopes that
# have exactly 1 match:

if (file.exists("matches.csv")) {
  t_matches <- readr::read_csv("matches.csv")
} else {
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
  readr::write_csv(t_matches, "matches.csv")
}
testthat::expect_true(file.exists("matches.csv"))
t_matches <- readr::read_csv("matches.csv")




#The question is, for unique mapping of an epitope onto the human reference proteome:
#are those epitopes indeed overlapping with a TMH?
if (!file.exists("unique_matches_pureseqtm.csv")) {
  t_unique_matches <- dplyr::filter(t_matches, n_matches == 1)
  t_unique_matches$pureseqtm_topology <- NA
  readr::write_csv(t_unique_matches, "unique_matches_pureseqtm.csv")
}
t_unique_matches <- readr::read_csv("unique_matches_pureseqtm.csv")

for (i in seq_len(nrow(t_unique_matches))) {
  print(paste0(i, "/", nrow(t_unique_matches)))
  if (!is.na(t_unique_matches$pureseqtm_topology[i])) next
  t_unique_matches$pureseqtm_topology[i] <- pureseqtmr::predict_topology_from_sequence(
    protein_sequence = t_unique_matches$sequence[i]
  )
  readr::write_csv(t_unique_matches, "unique_matches_pureseqtm.csv")
}


t_tmhs_pureseqtm <- t_unique_matches[
  stringr::str_which(
    t_unique_matches$pureseqtm_topology,
    "1"
  ),
]

testthat::expect_equal(
  nchar(t_tmhs_pureseqtm$sequence),
  nchar(t_tmhs_pureseqtm$pureseqtm_topology)
)

epitope_locations <- stringr::str_locate(
  string = t_tmhs_pureseqtm$sequence,
  pattern = t_tmhs_pureseqtm$epitope_sequence
)
epitope_locations
topology_overlap <- stringr::str_sub(
  t_tmhs_pureseqtm$pureseqtm_topology,
  start = epitope_locations[, 1],
  end = epitope_locations[, 2]
)
topology_overlap


t_tmhs_pureseqtm$topology_overlap <- topology_overlap
t_tmhs_pureseqtm$from <- epitope_locations[, 1]
t_tmhs_pureseqtm$to <- epitope_locations[, 2]
readr::write_csv(x = t_tmhs_pureseqtm, "tmhs_pureseqtm.csv")

t_tmhs_pureseqtm <- readr::read_csv("tmhs_pureseqtm.csv")

n <- length(t_tmhs_pureseqtm$topology_overlap)
n_tmh <- length(stringr::str_which(t_tmhs_pureseqtm$topology_overlap, pattern = "1"))
n_tmh / n
# 0.1119097 = 11.19097%