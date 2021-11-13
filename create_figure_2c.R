suppressWarnings(library(dplyr))

# Epitopes from IEDB
results_per_allele_filename <- "results_per_allele_per_allele.csv"
testthat::expect_true(file.exists(results_per_allele_filename))

# Predicted
prediction_results_1_filename <- "~/GitHubs/bbbq_1_smart/table_tmh_binders_mhc1_2.csv"
testthat::expect_true(file.exists(prediction_results_1_filename))
prediction_results_2_filename <- "~/GitHubs/bbbq_1_smart/table_tmh_binders_mhc2_2.csv"
testthat::expect_true(file.exists(prediction_results_2_filename))


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

t_scatter <- tidyr::pivot_wider(
  ts %>% select(allele_name, f_tmh, type), 
  names_from = type, 
  values_from = f_tmh
)
t_scatter <- t_scatter[!is.na(t_scatter$observed), ]
names(t_scatter)


p <- ggplot2::ggplot(t_scatter, 
  ggplot2::aes(x = observed, y = predicted)) +
  ggplot2::geom_point() +
  ggplot2::scale_x_continuous(
    "Epitopes derived from TMH\n(observed)",
    labels = scales::percent,
    limits = c(0.0, 0.5)
  ) +
  ggplot2::scale_y_continuous(
    "Epitopes derived from TMH\n(predicted)",
    labels = scales::percent,
    limits = c(0.0, 0.5)
  ) + ggplot2::geom_smooth(method = "lm", col = "red", fullrange = TRUE) +
  bbbq::get_bbbq_theme() +
  ggplot2::theme(text = ggplot2::element_text(size = 24)) +
  ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90))
p

p; ggplot2::ggsave("figure_2c.png", width = 180, units = "mm", height = 180)
p; ggplot2::ggsave("figure_2c.tiff", width = 180, units = "mm", height = 180)
p; ggplot2::ggsave("figure_2c.eps", width = 180, units = "mm", height = 180)
