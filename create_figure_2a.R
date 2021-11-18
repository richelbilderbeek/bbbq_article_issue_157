suppressWarnings(library(dplyr))

# Epitopes from IEDB
results_per_allele_filename <- "results_per_allele_per_allele.csv"
testthat::expect_true(file.exists(results_per_allele_filename))

# Predicted
prediction_results_1_filename <- "~/GitHubs/bbbq_1_smart/table_tmh_binders_mhc1_2.csv"
testthat::expect_true(file.exists(prediction_results_1_filename))
prediction_results_2_filename <- "~/GitHubs/bbbq_1_smart/table_tmh_binders_mhc2_2.csv"
testthat::expect_true(file.exists(prediction_results_2_filename))

coincidence_filename <- "~/GitHubs/bbbq_1_smart/table_coincidence.csv"
testthat::expect_true(file.exists(coincidence_filename))


t_iedb <- readr::read_csv(
  results_per_allele_filename,
  show_col_types = FALSE
)

# Only keep MHC ligand
t_iedb <- t_iedb[t_iedb$cell_type == "mhc_ligand", ]
t_iedb <- t_iedb %>% select(allele_name, f_tmh, n)
testthat::expect_equal(
  names(t_iedb),
  c("allele_name","f_tmh","n")
)




t_predictions_1 <- readr::read_csv(
  prediction_results_1_filename,
  show_col_types = FALSE
)
t_predictions_2 <- readr::read_csv(
  prediction_results_2_filename,
  show_col_types = FALSE
)
t_predictions <- dplyr::bind_rows(t_predictions_1, t_predictions_2)
t_predictions <- t_predictions %>% select(haplotype, human)
t_predictions <- dplyr::rename(t_predictions, allele_name = haplotype)

t_predictions$f_tmh <- stringr::str_match(
  string = t_predictions$human,
  pattern = "(.*) \\((.*)/(.*)\\)"
)[, 2]
t_predictions$n <- as.numeric(
  stringr::str_match(
    string = t_predictions$human,
    pattern = "(.*) \\((.*)/(.*)\\)"
  )[, 4]
)
t_predictions$human <- NULL
t_predictions$f_tmh <- as.numeric(t_predictions$f_tmh) / 100.0
testthat::expect_equal(
  names(t_predictions),
  c("allele_name","f_tmh","n")
)

t_coincidence_all <- readr::read_csv(
  coincidence_filename,
  show_col_types = FALSE
)
t_coincidence <- t_coincidence_all %>% 
  dplyr::filter(target == "human") %>%
  dplyr::select(mhc_class, conf_99_low, conf_99_high)

# Merge the tibbles
t_iedb$type <- "observed"
t_predictions$type <- "predicted"
ts <- dplyr::bind_rows(t_iedb, t_predictions)
ts$type <- as.factor(ts$type)

ts$mhc_class <- NA
ts$mhc_class[ts$allele_name %in% bbbq::get_mhc1_allele_names()] <- "I"
ts$mhc_class[ts$allele_name %in% bbbq::get_mhc2_allele_names()] <- "II"
ts$mhc_class[stringr::str_detect(ts$allele_name, "HLA-[AB]")] <- "I"
ts$mhc_class[stringr::str_detect(ts$allele_name, "HLA-D")] <- "II"
# Only keep MHC-I, as MHC-II has no overlap
ts <- ts[ts$mhc_class == "I", ]

# ts$allele_name <- bbbq::simplify_haplotype_names(ts$allele_name)
# Remove unknown alleles
#ts <- ts[!is.na(ts$allele_name), ]
#ts$allele_name <- paste0(ts$mhc_class, "_", ts$allele_name)
# readr::write_lines(x = ts$allele_name, "~/allele_names.txt")
ts

p <- ggplot2::ggplot(ts, 
  ggplot2::aes(x = allele_name, y = f_tmh, fill = type)) +
  ggplot2::geom_col(position = "dodge") +
  ggplot2::scale_y_continuous(
    "Epitopes derived from TMH",
    labels = scales::percent,
    limits = c(0.0, 0.5)
  ) +
  ggplot2::scale_x_discrete(
    "MHC allele name"
  ) + #ggplot2::geom_text(
      #ggplot2::aes(label = n),
      #vjust = -0.5,
      #size = 6
      #) +
  # ggplot2::facet_grid(
  #   . ~ mhc_class,
  #   scales = "free_x",
  #   labeller = ggplot2::as_labeller(
  #     c(
  #       I = "MHC-I", 
  #       II = "MHC-II"
  #     )
  #   )
  # ) + 
  ggplot2::geom_hline(color = "red", yintercept = (t_coincidence %>% filter(mhc_class == "I"))$conf_99_low) +
  ggplot2::geom_hline(color = "red", yintercept = (t_coincidence %>% filter(mhc_class == "I"))$conf_99_high) +
  bbbq::get_bbbq_theme() +
  ggplot2::theme(text = ggplot2::element_text(size = 24)) +
  ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90))
p

p; ggplot2::ggsave("figure_2a.png", width = 180, units = "mm", height = 180)
p; ggplot2::ggsave("figure_2a.tiff", width = 180, units = "mm", height = 180)
p; ggplot2::ggsave("figure_2a.eps", width = 180, units = "mm", height = 180)

if (1 == 2) {
  nrow(readr::read_csv("iedb_mhc_ligand_epitopes_and_mhc_alleles.csv", show_col_types = FALSE))
  nrow(readr::read_csv("iedb_mhc_ligand_per_allele_1.csv", show_col_types = FALSE))
  nrow(readr::read_csv("iedb_mhc_ligand_per_allele_2.csv", show_col_types = FALSE))
  nrow(readr::read_csv("matches_iedb_mhc_ligand_per_allele_1.csv", show_col_types = FALSE))
  nrow(readr::read_csv("matches_iedb_mhc_ligand_per_allele_2.csv", show_col_types = FALSE))
  nrow(readr::read_csv("tmhs_tmhmm_iedb_mhc_ligand_per_allele_1.csv", show_col_types = FALSE))
  nrow(readr::read_csv("tmhs_tmhmm_iedb_mhc_ligand_per_allele_2.csv", show_col_types = FALSE))
}