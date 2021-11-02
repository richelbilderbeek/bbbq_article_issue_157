t <- readr::read_csv(
  "results.csv",
  show_col_types = FALSE
)
t$mhc_class <- as.character(as.roman(t$mhc_class))
t$mhc_class <- as.factor(t$mhc_class)
t$tool <- as.factor(t$tool)
stop("Redo fig")
t$dataset[t$dataset == "schellens"] <- "non_iedb"
t$dataset[t$dataset == "bergseng"] <- "non_iedb"
t$dataset <- as.factor(t$dataset)

library(ggplot2)

p <- ggplot2::ggplot(t, ggplot2::aes(x = tool, y = f_tmh)) +
  ggplot2::geom_col(fill = "#BBBBBB") +
  ggplot2::scale_y_continuous(
    "Epitopes derived from TMH",
    labels = scales::percent
  ) +
  ggplot2::scale_x_discrete(
    "TMH prediction tool"
  ) +
  ggplot2::facet_grid(
    dataset ~ mhc_class,
    labeller = ggplot2::as_labeller(c(I = "MHC-I", II = "MHC-II", iedb = "IEDB", non_iedb = "non-IEDB"))
  ) + bbbq::get_bbbq_theme() +
  ggplot2::theme(text = ggplot2::element_text(size = 24))
p
p; ggplot2::ggsave("results.png", width = 180, units = "mm", height = 180)
p; ggplot2::ggsave("results.tiff", width = 180, units = "mm", height = 180)
p; ggplot2::ggsave("results.eps", width = 180, units = "mm", height = 180)
