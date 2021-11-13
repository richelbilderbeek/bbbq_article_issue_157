results_per_allele_filename <- "results_per_allele.csv"
testthat::expect_true(file.exists(results_per_allele_filename))

library(dplyr)
t <- readr::read_csv(
  results_per_allele_filename,
  show_col_types = FALSE
)
t
# Only keep T cells
t <- t[t$dataset == "iedb_t_cell", ]
t$mhc_class <- as.character(as.roman(t$mhc_class))
t$mhc_class <- as.factor(t$mhc_class)
p <- ggplot2::ggplot(t, 
  ggplot2::aes(x = mhc_class, y = f_tmh)) +
  ggplot2::geom_col(fill = "#BBBBBB") +
  ggplot2::scale_y_continuous(
    "Epitopes derived from TMH",
    labels = scales::percent,
    limits = c(0.0, 0.5)
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

p; ggplot2::ggsave("figure_2d.png", width = 180, units = "mm", height = 180)
p; ggplot2::ggsave("figure_2d.tiff", width = 180, units = "mm", height = 180)
p; ggplot2::ggsave("figure_2d.eps", width = 180, units = "mm", height = 180)

if (1 == 2) {
  readr::read_csv("iedb_t_cell_epitopes_and_mhc_alleles.csv", show_col_types = FALSE)
  readr::read_csv("iedb_t_cell_per_allele_1.csv", show_col_types = FALSE)
  readr::read_csv("iedb_t_cell_per_allele_2.csv", show_col_types = FALSE)
  t <- readr::read_csv("matches_iedb_t_cell_per_allele_1.csv", show_col_types = FALSE)
  readr::read_csv("matches_iedb_t_cell_per_allele_2.csv", show_col_types = FALSE)
  nrow(readr::read_csv("tmhs_tmhmm_iedb_t_cell_per_allele_1.csv", show_col_types = FALSE))
  nrow(readr::read_csv("tmhs_tmhmm_iedb_t_cell_per_allele_2.csv", show_col_types = FALSE))
}
