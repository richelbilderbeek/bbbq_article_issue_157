results_per_allele_filename <- "results_per_allele.csv"
testthat::expect_true(file.exists(results_per_allele_filename))

library(dplyr)
t <- readr::read_csv(
  results_per_allele_filename,
  show_col_types = FALSE
)
t
# Only keep MHC ligand
t <- t[t$dataset == "iedb_mhc_ligand", ]
t$mhc_class <- as.character(as.roman(t$mhc_class))
t$mhc_class <- as.factor(t$mhc_class)

# Coincidence interval
coincidence_filename <- "~/GitHubs/bbbq_1_smart/table_coincidence.csv"
testthat::expect_true(file.exists(coincidence_filename))
t_coincidence_all <- readr::read_csv(
  coincidence_filename,
  show_col_types = FALSE
)
t_coincidence <- t_coincidence_all %>% 
  dplyr::filter(target == "human") %>%
  dplyr::select(mhc_class, conf_99_low, f_tmh, conf_99_high)

p <- ggplot2::ggplot(t, 
  ggplot2::aes(x = mhc_class, y = f_tmh)) +
  ggplot2::geom_col(fill = "#BBBBBB") +
  ggplot2::geom_errorbar(data = t_coincidence, ggplot2::aes(x = mhc_class, ymin = conf_99_low, ymax = conf_99_high), col = "red") +
  ggplot2::scale_y_continuous(
    "Epitopes derived from TMH",
    labels = scales::percent,
    limits = c(0.0, 0.4)
  ) +
  ggplot2::scale_x_discrete(
    "MHC class"
  ) + ggplot2::geom_text(
    ggplot2::aes(label = n),
    vjust = -0.5,
    size = 8
  )  + bbbq::get_bbbq_theme() +
  ggplot2::theme(text = ggplot2::element_text(size = 24))
p

p; ggplot2::ggsave("figure_2b.png", width = 180, units = "mm", height = 180)
p; ggplot2::ggsave("figure_2b.tiff", width = 180, units = "mm", height = 180)
p; ggplot2::ggsave("figure_2b.eps", width = 180, units = "mm", height = 180)