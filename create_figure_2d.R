library(dplyr)
t <- readr::read_csv(
  "results.csv",
  show_col_types = FALSE
)

# Remove NAs
t <- t[!is.na(t$f_tmh), ]
t
# Only keep T cells
t <- t[t$dataset == "iedb_t_cell", ]
t
# Only keep TMHMM
t <- t[t$tool == "TMHMM", ]
t

t_iedb_t_cell <- readr::read_csv(
  "iedb_t_cell.csv",
  show_col_types = FALSE
)


t_1 <- readr::read_csv(
  "tmhs_tmhmm_iedb_t_cell_1.csv",
  show_col_types = FALSE
)
t_2 <- readr::read_csv(
  "tmhs_tmhmm_iedb_t_cell_2.csv",
  show_col_types = FALSE
)
t_1$mhc_class <- "I"
t_1$is_tmh_derived_epitope <- stringr::str_detect(
  string = t_1$topology_overlap, 
  pattern = "[mM]"
)
t_2$mhc_class <- "II"
t_2$is_tmh_derived_epitope <- stringr::str_detect(
  string = t_2$topology_overlap, 
  pattern = "[mM]"
)
t_1_and_2 <- dplyr::bind_rows(
  t_1 %>% select(mhc_class, epitope_sequence, is_tmh_derived_epitope),
  t_2 %>% select(mhc_class, epitope_sequence, is_tmh_derived_epitope)
)

t_is_tmh_derived_epitope_per_haplotype_1_and_2 <- merge(
  x = t_1_and_2,
  y = t_iedb_t_cell,
  by.x = "epitope_sequence", 
  by.y = "linear_sequence"
)
f_tmh_derived_epitope_per_haplotype_1_and_2 <- t_is_tmh_derived_epitope_per_haplotype_1_and_2 %>% 
  group_by(haplotype) %>%
  dplyr::summarize(
    f_tmh_derived = mean(is_tmh_derived_epitope)
  )
f_tmh_derived_epitope_per_haplotype_1_and_2

f_tmh_derived_epitope_per_haplotype_1_and_2$mhc_class <- "II"
f_tmh_derived_epitope_per_haplotype_1_and_2$mhc_class[
  f_tmh_derived_epitope_per_haplotype_1_and_2$haplotype %in% bbbq::get_mhc1_haplotypes()
] <- "I"

f_tmh_derived_epitope_per_haplotype_1_and_2$mhc_class <- as.factor(f_tmh_derived_epitope_per_haplotype_1_and_2$mhc_class)
f_tmh_derived_epitope_per_haplotype_1_and_2$haplotype <- as.factor(f_tmh_derived_epitope_per_haplotype_1_and_2$haplotype)

p <- ggplot2::ggplot(f_tmh_derived_epitope_per_haplotype_1_and_2, 
  ggplot2::aes(x = haplotype, y = f_tmh_derived)) +
  ggplot2::geom_col(fill = "#BBBBBB") +
  ggplot2::scale_y_continuous(
    "Epitopes derived from TMH",
    labels = scales::percent
  ) +
  ggplot2::scale_x_discrete(
    "MHC allele"
  ) +
  ggplot2::facet_grid(
    . ~ mhc_class,
    scales = "free_x",
    labeller = ggplot2::as_labeller(
      c(
        I = "MHC-I", 
        II = "MHC-II"
      )
    )
  ) + bbbq::get_bbbq_theme() +
  ggplot2::theme(text = ggplot2::element_text(size = 24)) +
  ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90))
p

p; ggplot2::ggsave("figure_2d.png", width = 180, units = "mm", height = 180)
p; ggplot2::ggsave("figure_2d.tiff", width = 180, units = "mm", height = 180)
p; ggplot2::ggsave("figure_2d.eps", width = 180, units = "mm", height = 180)
