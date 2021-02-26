library(dplyr, warn.conflicts = FALSE)

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
  pattern = paste0("[[:upper:]]{5}", t_unique$epitope_sequence)
)[, 1]
t_matches <- t_matches[!is.na(t_matches)]

readr::write_lines(t_matches, "~/five_before_epitopes.txt")
readr::write_csv(
  analyse_epitopes(t_matches, positions = c(1, 2, 3, 4, 5)),
  "~/five_before_epitopes.csv"
)

# The five epitopes after
t_matches <- stringr::str_match(
  string = t_unique$sequence,
  pattern = paste0(t_unique$epitope_sequence, "[[:upper:]]{5}")
)[, 1]
t_matches <- t_matches[!is.na(t_matches)]

readr::write_lines(t_matches, "~/five_after_epitopes.txt")
readr::write_csv(
  analyse_epitopes(t_matches, positions = c(-5, -4, -3, -2, -1)),
  "~/five_after_epitopes.csv"
)
