# Moved to https://github.com/richelbilderbeek/bbbq_article_issue_191
library(dplyr, warn.conflicts = FALSE)

# How many AAs before and after the epitope
n <- 10

#' Analyse the epitopes
#' @param epitope_sequences sequences of epitopes
#' @param positions string positions as used by \link[stringr]{str_sub}, e.g. '1' denotes the first character,
#'   '-1' means the last character, '-2' the one-but-last
analyse_epitopes <- function(
  epitope_sequences,
  positions = c(1, 2, 3, 4, 5)
) {
  testthat::expect_true(is.character(epitope_sequences))
  testthat::expect_true(is.numeric(positions))
  # Store sequences as tibble, as stringr needs it
  char_tibble <- tibble::tibble(
    epitope_sequence = epitope_sequences
  )

  # Collect all tibbles in this list
  tibbles <- list()

  # Count all chararacters at all positions
  for (i in seq_along(positions)) {
    pos <- positions[i]
    testthat::expect_true(all(nchar(char_tibble$epitope_sequence) >= abs(pos)))
    char_tibble$char <- stringr::str_sub(char_tibble$epitope_sequence, pos, pos)
    t <- dplyr::count(char_tibble, char)
    t$pos <- pos
    t <- dplyr::relocate(t, pos)
    tibbles[[i]] <- t
  }
  # Combine the reults per position
  t_all <- dplyr::bind_rows(tibbles)

  # Convert the data to wide format for Libreoffice Calc users
  t_wide <- tidyr::pivot_wider(t_all, names_from = pos, values_from = n) %>% dplyr::arrange(char)

  # Make the column names reader friendly
  names(t_wide) <- c(
    names(t_wide)[1],
    stringr::str_replace(english::as.english(as.numeric(names(t_wide)[-1])), " ", "_")
  )

  return(t_wide)
}

# Collect all the MHC-I matches
t <- readr::read_csv("matches_1.csv")
# Keep the uniquely mapped epitopes
t_unique <- t %>% dplyr::filter(!is.na(gene_name))

# The five epitopes before
t_matches <- stringr::str_match(
  string = t_unique$sequence,
  pattern = paste0("[[:upper:]]{", n, "}", t_unique$epitope_sequence)
)[, 1]
t_matches <- t_matches[!is.na(t_matches)]
testthat::expect_equal(6933, length(t_matches))
readr::write_lines(
  t_matches,
  paste0("~/", english::as.english(n) ,"_before_epitopes.txt")
)
readr::write_csv(
  analyse_epitopes(t_matches, positions = seq(1, n)),
  paste0("~/", english::as.english(n) ,"_before_epitopes.csv")
)
t <- tibble::tibble(
  name = paste0("iloverichel", seq_len(length(t_matches))),
  sequence = stringr::str_sub(t_matches, 1, n)
)
pureseqtmr::save_tibble_as_fasta_file(
  t,
  paste0("~/", english::as.english(n) ,"_before_epitopes.fasta")
)

# The five epitopes after
t_matches <- stringr::str_match(
  string = t_unique$sequence,
  pattern = paste0(t_unique$epitope_sequence, "[[:upper:]]{", n, "}")
)[, 1]
t_matches <- t_matches[!is.na(t_matches)]
testthat::expect_equal(6771, length(t_matches))

readr::write_lines(
  t_matches,
  paste0("~/", english::as.english(n) ,"_after_epitopes.txt")
)
readr::write_csv(
  analyse_epitopes(t_matches, positions = seq(-n, -1)),
  paste0("~/", english::as.english(n) ,"_after_epitopes.csv")
)

t <- tibble::tibble(
  name = paste0("iloverichel", seq_len(length(t_matches))),
  sequence = stringr::str_sub(t_matches, -n)
)
pureseqtmr::save_tibble_as_fasta_file(
  t,
  paste0("~/", english::as.english(n) ,"_after_epitopes.fasta")
)

# First epitope:
# MEKSSLTQHSW, see to the right where it is alignmed
# ---->                                                                                                                                                                 MEKSSLTQHSW                                                                                                                                                                                                                               # nolint indeed long
# MAEAMDLGKDPNGPTHSSTLFVRDDGSSMSFYVRPSPAKRRLSTLILHGGGTVCRVQEPGAVLLAQPGEALAEASGDFISTQYILDCVERNERLELEAYRLGPASAADTGSEAKPGALAEGAAEPEPQRHAGRIAFTDADDVAILTYVKENARSPSSVTGNALWKAMEKSSLTQHSWQSLKDRYLKHLRGQEHKYLLGDAPVSPSSQKLKRKAEEDPEAADSGEPQNKRTPDLPEEEYVKEEIQENEEAVKKMLVEATREFEEVVVDESPPDFEIHITMCDDDPPTPEEDSETQPDEEEEEEEEKVSQPEVGAAIKIIRQLMEKFNLDLSTVTQAFLKNSGELEATSAFLASGQRADGYPIWSRQDDIDLQKDDEDTREALVKKFGAQNVARRIEFRKK # nolint indeed long


# Also, count the percentage of fragments that can be mapped to a proteome (i.e. including duplicates).
t_schellens <- bianchietal2017::get_schellens_et_al_2015_sup_1(
  xlsx_filename = bianchietal2017::download_schellens_et_al_2015_sup_1(
    xlsx_filename = "schellens_et_al_2015.xlsl"
  )
)
n_epitopes <- nrow(t_schellens)
testthat::expect_equal(10894, n_epitopes)
n_unique_epitopes <- length(unique(t_schellens$epitope_sequence))
testthat::expect_equal(7897, n_unique_epitopes)

# Bos Taurus proteome, from https://www.uniprot.org/proteomes/UP000009136
utils::download.file(
  url = "http://richelbilderbeek.nl/UP000009136.fasta",
  destfile = "UP000009136.fasta",
  quiet = TRUE
)
t_cow <- pureseqtmr::load_fasta_file_as_tibble("UP000009136.fasta")
t_human <- bbbq::get_proteome()
epitope_sequences <- unique(t_schellens$epitope_sequence)
length(epitope_sequences)
t_matches <- tibble::tibble(
  epitope_sequence = epitope_sequences,
  n_matches_human = NA,
  n_matches_cow = NA
)
for (i in seq_len(nrow(t_matches))) {
  print(paste0(i, "/", nrow(t_matches)))
  matches_human <- stringr::str_which(
    string =  t_human$sequence,
    pattern = t_matches$epitope_sequence[i]
  )
  t_matches$n_matches_human[i] <- length(matches_human)
  matches_cow <- stringr::str_which(
    string =  t_cow$sequence,
    pattern = t_matches$epitope_sequence[i]
  )
  t_matches$n_matches_cow[i] <- length(matches_cow)
}
t_matches
readr::write_csv(x = t_matches, "~/n_matches.csv")

text <- paste0(
  "number of unique epitopes: ", length(epitope_sequences), "\n",
  "number of epitopes map to a human proteome: ",
    sum(t_matches$n_matches_human != 0),
    "\n",
  "number of epitopes map to a cow proteome: ",
    sum(t_matches$n_matches_cow != 0),
    "\n"
)
readr::write_lines(x = text, "~/n_matches.txt")
